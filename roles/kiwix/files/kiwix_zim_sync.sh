#!/bin/bash
#
# Kiwix ZIM Sync Manager
# Updates URL file from Kiwix and syncs local downloads
#
# Usage:
#   ./kiwix_zim_sync.sh <command> [OPTIONS]
#
# Commands:
#   update    - Check Kiwix for newer versions, update URL file
#   download  - Download files from URL list, cleanup old versions
#   sync      - Do both: update URLs then download files
#   verify    - Verify existing downloads are complete
#
# Options:
#   -u, --urls FILE   URL file path (default: ./zim_files/zim_urls.txt)
#   -p, --path DIR    Download directory (default: ./zim_files)
#   -a, --auto        Auto mode - no prompts
#   -d, --dry-run     Show what would be done without doing it
#   --keep-old        Don't delete old versions (download/sync)
#   -h, --help        Show help
#

set -euo pipefail

# === Configuration ===
readonly VERSION="1.0.0"
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly DEFAULT_URL_FILE="${SCRIPT_DIR}/zim_files/zim_urls.txt"
readonly DEFAULT_DOWNLOAD_DIR="${SCRIPT_DIR}/zim_files"
readonly KIWIX_BASE_URL="https://download.kiwix.org/zim"

# Download settings
readonly ARIA2C_CONNECTIONS=16
readonly ARIA2C_SPLIT=16
readonly ARIA2C_MAX_TRIES=3
readonly ARIA2C_TIMEOUT=300
readonly WGET_TIMEOUT=300

# === Global State ===
COMMAND=""
URL_FILE=""
DOWNLOAD_DIR=""
AUTO_MODE=false
DRY_RUN=false
KEEP_OLD=false

declare -A URL_ENTRIES=()           # url -> 1
declare -A URL_PATTERNS=()          # base_pattern -> url (from URL file)
declare -A LOCAL_FILES=()           # filename -> full_path
declare -A LOCAL_PATTERNS=()        # base_pattern -> filename

# Update state
declare -A UPDATES_AVAILABLE=()     # old_url -> new_url|size
declare -a UPDATE_LIST=()           # Ordered list of old URLs with updates
declare -A SELECTED_UPDATES=()      # old_url -> 1

# Download state
declare -a TO_DOWNLOAD=()           # URLs to download
declare -a OLD_FILES=()             # Old local files
declare -A OLD_FILE_PROTECTED=()    # filename -> 1 (protected)
declare -A SELECTED_DOWNLOADS=()    # url -> 1
declare -A SELECTED_DELETIONS=()    # filename -> 1

# Stats
STAT_URLS_UPDATED=0
STAT_DOWNLOADED=0
STAT_SKIPPED=0
STAT_FAILED=0
STAT_DELETED=0

# === Logging ===
log_info()    { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; }
log_update()  { echo -e "${CYAN}[UPDATE]${NC} $1"; }
log_download(){ echo -e "${CYAN}[DOWNLOAD]${NC} $1"; }
log_delete()  { echo -e "${YELLOW}[DELETE]${NC} $1"; }
log_protect() { echo -e "${BLUE}[PROTECT]${NC} $1"; }

clear_screen() { [[ -t 1 ]] && clear 2>/dev/null || true; }

# === Help ===
show_help() {
    cat << 'EOF'
Kiwix ZIM Sync Manager

Keeps your ZIM files up to date by checking Kiwix for newer versions
and syncing your local downloads.

Usage: kiwix_zim_sync.sh <command> [OPTIONS]

Commands:
  update    Check Kiwix for newer versions and update URL file
  download  Download files from URL list, cleanup old local versions
  sync      Do both: update URLs then download (recommended for cron)
  verify    Verify existing downloads are complete (size check)

Options:
  -u, --urls FILE   URL file path (default: ./zim_files/zim_urls.txt)
  -p, --path DIR    Download directory (default: ./zim_files)
  -a, --auto        Auto mode - no interactive prompts
  -d, --dry-run     Show what would be done without doing it
  --keep-old        Don't delete old versions (download/sync only)
  -h, --help        Show this help

Examples:
  kiwix_zim_sync.sh update                 # Interactive: check for URL updates
  kiwix_zim_sync.sh download               # Interactive: download and cleanup
  kiwix_zim_sync.sh sync                   # Interactive: full sync
  kiwix_zim_sync.sh sync -a                # Auto: full sync (for cron)
  kiwix_zim_sync.sh sync -a --keep-old     # Auto: sync but keep old versions
  kiwix_zim_sync.sh sync -d                # Dry run: show what would happen
  kiwix_zim_sync.sh verify                 # Verify existing files

Behavior:
  UPDATE:   Queries Kiwix for each URL pattern, replaces old URLs with newer
  DOWNLOAD: Downloads missing files, deletes old versions (with protection)
  SYNC:     Runs update first, then download
  
  Orphan Protection: Old local files are NEVER deleted if they no longer
  exist on Kiwix - they are protected forever.

Cron example (weekly full sync):
  0 3 * * 0 /path/to/kiwix_zim_sync.sh sync -a >> /var/log/kiwix.log 2>&1

EOF
    exit 0
}

# === Argument Parsing ===
parse_args() {
    [[ $# -eq 0 ]] && { show_help; exit 0; }
    
    # First argument is the command
    case "$1" in
        update|download|sync|verify)
            COMMAND="$1"
            shift
            ;;
        -h|--help)
            show_help
            ;;
        *)
            log_error "Unknown command: $1"
            echo "Use -h for help"
            exit 1
            ;;
    esac
    
    URL_FILE="$DEFAULT_URL_FILE"
    DOWNLOAD_DIR="$DEFAULT_DOWNLOAD_DIR"
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -u|--urls)
                URL_FILE="$2"
                shift 2
                ;;
            -p|--path)
                DOWNLOAD_DIR="$2"
                shift 2
                ;;
            -a|--auto)
                AUTO_MODE=true
                shift
                ;;
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            --keep-old)
                KEEP_OLD=true
                shift
                ;;
            -h|--help)
                show_help
                ;;
            *)
                log_error "Unknown option: $1"
                echo "Use -h for help"
                exit 1
                ;;
        esac
    done
}

# === Shared Utility Functions ===

check_dependencies() {
    if ! command -v curl &>/dev/null; then
        log_error "curl is required"
        exit 1
    fi
    
    if [[ "$COMMAND" == "download" || "$COMMAND" == "sync" ]]; then
        if ! command -v aria2c &>/dev/null && ! command -v wget &>/dev/null; then
            log_error "Either aria2c or wget is required for downloading"
            exit 1
        fi
    fi
}

# Parse ZIM filename to extract base pattern and date
parse_zim_filename() {
    local filename=$1
    filename="${filename%.zim}"
    
    if [[ "$filename" =~ ^(.+)_([0-9]{4}-[0-9]{2})$ ]]; then
        echo "${BASH_REMATCH[1]}|${BASH_REMATCH[2]}"
    else
        echo "${filename}|"
    fi
}

# Extract category from URL
get_category_from_url() {
    local url=$1
    echo "$url" | sed -n 's|.*/zim/\([^/]*\)/.*|\1|p'
}

# Format file size for display
format_size() {
    local bytes=$1
    [[ -z "$bytes" || "$bytes" == "0" ]] && { echo "unknown"; return; }
    
    local gb=$(awk "BEGIN {printf \"%.2f\", $bytes / 1073741824}")
    if awk "BEGIN {exit !($gb < 1.0)}"; then
        awk "BEGIN {printf \"%.1fMB\", $bytes / 1048576}"
    else
        echo "${gb}GB"
    fi
}

# Get file size (cross-platform)
get_file_size() {
    local file=$1
    stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo "0"
}

# Get expected size from URL headers
get_remote_size() {
    local url=$1
    curl -sI "$url" 2>/dev/null | grep -i "content-length" | awk '{print $2}' | tr -d '\r\n'
}

# Check if local file is complete
is_file_complete() {
    local file_path=$1
    local url=$2
    
    [[ ! -f "$file_path" ]] && return 1
    
    local expected=$(get_remote_size "$url")
    [[ -z "$expected" || "$expected" == "0" ]] && return 0
    
    local actual=$(get_file_size "$file_path")
    [[ "$actual" -eq "$expected" ]]
}

# Check if pattern exists on Kiwix (for orphan protection)
check_pattern_exists_on_kiwix() {
    local category=$1
    local base_pattern=$2
    
    local temp_html=$(mktemp)
    trap "rm -f '$temp_html'" RETURN
    
    if ! curl -s --max-time 15 "${KIWIX_BASE_URL}/${category}/" > "$temp_html" 2>/dev/null; then
        return 1
    fi
    
    [[ ! -s "$temp_html" ]] && return 1
    
    grep -q "href=\"${base_pattern}_[0-9]" "$temp_html"
}

# Load URLs from file
load_url_file() {
    if [[ ! -f "$URL_FILE" ]]; then
        log_error "URL file not found: $URL_FILE"
        exit 1
    fi
    
    while IFS= read -r line; do
        [[ -z "$line" || "$line" == \#* ]] && continue
        [[ "$line" =~ ^https?:// ]] || continue
        
        URL_ENTRIES["$line"]=1
        
        local filename=$(basename "$line")
        local parsed=$(parse_zim_filename "$filename")
        local base="${parsed%|*}"
        
        URL_PATTERNS["$base"]="$line"
    done < "$URL_FILE"
    
    log_info "Loaded ${#URL_ENTRIES[@]} URLs from file"
}

# Scan local ZIM files
scan_local_files() {
    [[ ! -d "$DOWNLOAD_DIR" ]] && { mkdir -p "$DOWNLOAD_DIR"; return; }
    
    while IFS= read -r -d '' filepath; do
        local filename=$(basename "$filepath")
        LOCAL_FILES["$filename"]="$filepath"
        
        local parsed=$(parse_zim_filename "$filename")
        local base="${parsed%|*}"
        local date="${parsed#*|}"
        
        local existing="${LOCAL_PATTERNS[$base]:-}"
        if [[ -z "$existing" ]]; then
            LOCAL_PATTERNS["$base"]="$filename"
        else
            local existing_parsed=$(parse_zim_filename "$existing")
            local existing_date="${existing_parsed#*|}"
            [[ "$date" > "$existing_date" ]] && LOCAL_PATTERNS["$base"]="$filename"
        fi
    done < <(find "$DOWNLOAD_DIR" -maxdepth 1 -name "*.zim" -type f -print0 2>/dev/null)
    
    log_info "Found ${#LOCAL_FILES[@]} local ZIM files"
}

# === Interactive Selection (shared UI pattern) ===

# Generic toggle selection menu
# Args: title, items_array_name, state_array_name, display_callback
run_selection_menu() {
    local title=$1
    local -n items=$2
    local -n selected=$3
    local display_callback=$4
    
    local item_count=${#items[@]}
    [[ $item_count -eq 0 ]] && return
    
    if [[ "$AUTO_MODE" == "true" ]]; then
        # Auto mode: select all
        for item in "${items[@]}"; do
            selected["$item"]=1
        done
        return
    fi
    
    # State file
    local state_file=$(mktemp)
    trap "rm -f '$state_file'" RETURN
    
    # Initialize all as selected
    for ((i=0; i<item_count; i++)); do
        echo "1" >> "$state_file"
    done
    
    while true; do
        clear_screen
        log_info "=== ${title} ==="
        echo ""
        
        # Read state
        local -a state=()
        while IFS= read -r line; do
            state+=("$line")
        done < "$state_file"
        
        # Display items
        local sel_count=0
        for i in "${!items[@]}"; do
            local mark="[ ]"
            if [[ "${state[$i]}" == "1" ]]; then
                mark="[X]"
                sel_count=$((sel_count + 1))
            fi
            
            # Call display callback
            $display_callback "$((i+1))" "$mark" "${items[$i]}"
        done
        
        echo ""
        log_info "Selected: ${sel_count}/${item_count}"
        echo ""
        log_info "Toggle: 1,3,5 or 1-5 | all | none | Enter=proceed"
        echo ""
        read -p "> " input
        
        [[ -z "$input" ]] && break
        
        if [[ "$input" == "all" ]]; then
            for i in "${!state[@]}"; do state[$i]=1; done
            printf '%s\n' "${state[@]}" > "$state_file"
            continue
        fi
        if [[ "$input" == "none" ]]; then
            for i in "${!state[@]}"; do state[$i]=0; done
            printf '%s\n' "${state[@]}" > "$state_file"
            continue
        fi
        
        # Parse and toggle
        local -a parts=()
        IFS=', ' read -ra parts <<< "$input"
        
        for part in "${parts[@]}"; do
            [[ -z "$part" ]] && continue
            
            local start_n end_n
            if [[ "$part" =~ ^([0-9]+)-([0-9]+)$ ]]; then
                start_n=${BASH_REMATCH[1]}
                end_n=${BASH_REMATCH[2]}
            elif [[ "$part" =~ ^[0-9]+$ ]]; then
                start_n=$((10#$part))
                end_n=$start_n
            else
                continue
            fi
            
            for ((n=start_n; n<=end_n; n++)); do
                if [[ $n -ge 1 && $n -le $item_count ]]; then
                    local idx=$((n - 1))
                    [[ "${state[$idx]}" == "1" ]] && state[$idx]=0 || state[$idx]=1
                fi
            done
        done
        
        printf '%s\n' "${state[@]}" > "$state_file"
    done
    
    # Build selected
    local -a state=()
    while IFS= read -r line; do
        state+=("$line")
    done < "$state_file"
    
    for i in "${!items[@]}"; do
        [[ "${state[$i]}" == "1" ]] && selected["${items[$i]}"]=1
    done
}

# === UPDATE Command Functions ===

# Fetch latest version from Kiwix
fetch_latest_version() {
    local category=$1
    local base_pattern=$2
    
    local temp_html=$(mktemp)
    trap "rm -f '$temp_html'" RETURN
    
    curl -s --max-time 15 "${KIWIX_BASE_URL}/${category}/" > "$temp_html" 2>/dev/null
    [[ ! -s "$temp_html" ]] && return
    
    local latest_url="" latest_date="" latest_size=""
    
    while IFS= read -r line; do
        [[ ! "$line" =~ \.zim ]] && continue
        
        local filename=$(echo "$line" | grep -oP 'href="([^"]+\.zim)"' | sed 's/href="//;s/"//')
        [[ -z "$filename" ]] && continue
        
        local parsed=$(parse_zim_filename "$filename")
        local file_base="${parsed%|*}"
        local file_date="${parsed#*|}"
        
        if [[ "$file_base" == "$base_pattern" ]]; then
            if [[ -z "$latest_date" ]] || [[ "$file_date" > "$latest_date" ]]; then
                latest_date="$file_date"
                latest_url="${KIWIX_BASE_URL}/${category}/${filename}"
                
                local size_str=$(echo "$line" | sed -n 's/.*[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}\s\+[0-9]\{2\}:[0-9]\{2\}\s\+\([0-9.]\+[GMK]\?\).*/\1/p')
                if [[ "$size_str" =~ ^([0-9.]+)G$ ]]; then
                    latest_size=$(awk "BEGIN {printf \"%.0f\", ${BASH_REMATCH[1]} * 1073741824}")
                elif [[ "$size_str" =~ ^([0-9.]+)M$ ]]; then
                    latest_size=$(awk "BEGIN {printf \"%.0f\", ${BASH_REMATCH[1]} * 1048576}")
                fi
            fi
        fi
    done < "$temp_html"
    
    [[ -n "$latest_url" ]] && echo "${latest_url}|${latest_size:-0}"
}

# Check for URL updates
check_for_updates() {
    log_info "Checking Kiwix for updates..."
    echo ""
    
    declare -A files_to_check=()
    
    for url in "${!URL_ENTRIES[@]}"; do
        local filename=$(basename "$url")
        local category=$(get_category_from_url "$url")
        local parsed=$(parse_zim_filename "$filename")
        local base="${parsed%|*}"
        local date="${parsed#*|}"
        
        local existing="${files_to_check[$base]:-}"
        if [[ -z "$existing" ]]; then
            files_to_check["$base"]="${category}|${url}|${date}"
        else
            local existing_date="${existing##*|}"
            [[ "$date" > "$existing_date" ]] && files_to_check["$base"]="${category}|${url}|${date}"
        fi
    done
    
    local total=${#files_to_check[@]}
    local checked=0
    
    for base in "${!files_to_check[@]}"; do
        checked=$((checked + 1))
        local info="${files_to_check[$base]}"
        local category="${info%%|*}"
        local rest="${info#*|}"
        local current_url="${rest%%|*}"
        local current_date="${rest#*|}"
        
        printf "\r  [%d/%d] Checking: %-40s" "$checked" "$total" "$base"
        
        local latest=$(fetch_latest_version "$category" "$base")
        if [[ -n "$latest" ]]; then
            local latest_url="${latest%|*}"
            local latest_size="${latest#*|}"
            local latest_filename=$(basename "$latest_url")
            local latest_parsed=$(parse_zim_filename "$latest_filename")
            local latest_date="${latest_parsed#*|}"
            
            if [[ "$latest_date" > "$current_date" ]]; then
                UPDATES_AVAILABLE["$current_url"]="${latest_url}|${latest_size}"
                UPDATE_LIST+=("$current_url")
            fi
        fi
    done
    
    printf "\r%80s\r" ""
    echo ""
    
    if [[ ${#UPDATES_AVAILABLE[@]} -eq 0 ]]; then
        log_info "All URLs are up to date!"
        return 1
    fi
    
    log_info "Found ${#UPDATES_AVAILABLE[@]} updates available"
    return 0
}

# Display callback for update selection
display_update_item() {
    local num=$1 mark=$2 old_url=$3
    
    local info="${UPDATES_AVAILABLE[$old_url]}"
    local new_url="${info%|*}"
    local size="${info#*|}"
    
    local old_file=$(basename "$old_url")
    local new_file=$(basename "$new_url")
    local old_parsed=$(parse_zim_filename "$old_file")
    local new_parsed=$(parse_zim_filename "$new_file")
    local base="${old_parsed%|*}"
    local old_date="${old_parsed#*|}"
    local new_date="${new_parsed#*|}"
    
    printf "  %3d) %s %-40s %s -> %s  (%s)\n" \
        "$num" "$mark" "$base" "$old_date" "$new_date" "$(format_size "$size")"
}

# Apply URL updates to file
apply_url_updates() {
    local selected_count=${#SELECTED_UPDATES[@]}
    
    if [[ $selected_count -eq 0 ]]; then
        log_info "No updates selected"
        return
    fi
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo ""
        log_warn "DRY RUN - Would update these URLs:"
        for old_url in "${!SELECTED_UPDATES[@]}"; do
            local info="${UPDATES_AVAILABLE[$old_url]}"
            local new_url="${info%|*}"
            echo "  $(basename "$old_url") -> $(basename "$new_url")"
        done
        echo ""
        log_info "[DRY RUN] Would update ${selected_count} URLs"
        return
    fi
    
    local temp_file="${URL_FILE}.tmp"
    
    while IFS= read -r line; do
        if [[ -z "$line" || "$line" == \#* ]]; then
            echo "$line" >> "$temp_file"
            continue
        fi
        
        if [[ -n "${SELECTED_UPDATES[$line]:-}" ]]; then
            local info="${UPDATES_AVAILABLE[$line]}"
            local new_url="${info%|*}"
            echo "$new_url" >> "$temp_file"
            STAT_URLS_UPDATED=$((STAT_URLS_UPDATED + 1))
            log_update "$(basename "$line") -> $(basename "$new_url")"
        else
            echo "$line" >> "$temp_file"
        fi
    done < "$URL_FILE"
    
    mv "$temp_file" "$URL_FILE"
    log_info "Updated ${STAT_URLS_UPDATED} URLs in file"
}

# === DOWNLOAD Command Functions ===

# Find files to download and old versions
find_downloads_and_old_files() {
    # Files to download
    for url in "${!URL_ENTRIES[@]}"; do
        local filename=$(basename "$url")
        local file_path="${DOWNLOAD_DIR}/${filename}"
        
        if [[ ! -f "$file_path" ]] || ! is_file_complete "$file_path" "$url"; then
            TO_DOWNLOAD+=("$url")
        fi
    done
    
    # Old local files
    for filename in "${!LOCAL_FILES[@]}"; do
        local parsed=$(parse_zim_filename "$filename")
        local base="${parsed%|*}"
        local date="${parsed#*|}"
        
        local url="${URL_PATTERNS[$base]:-}"
        [[ -z "$url" ]] && continue
        
        local url_file=$(basename "$url")
        local url_parsed=$(parse_zim_filename "$url_file")
        local url_date="${url_parsed#*|}"
        
        if [[ -n "$url_date" && -n "$date" && "$url_date" > "$date" ]]; then
            OLD_FILES+=("$filename")
        fi
    done
    
    log_info "Files to download: ${#TO_DOWNLOAD[@]}"
    log_info "Old versions found: ${#OLD_FILES[@]}"
}

# Check orphan protection
check_orphan_protection() {
    [[ ${#OLD_FILES[@]} -eq 0 ]] && return
    
    log_info "Checking orphan protection..."
    
    local checked=0
    local total=${#OLD_FILES[@]}
    
    for filename in "${OLD_FILES[@]}"; do
        checked=$((checked + 1))
        printf "\r  [%d/%d] Checking: %-40s" "$checked" "$total" "$filename"
        
        local parsed=$(parse_zim_filename "$filename")
        local base="${parsed%|*}"
        
        local url="${URL_PATTERNS[$base]:-}"
        if [[ -z "$url" ]]; then
            OLD_FILE_PROTECTED["$filename"]=1
            continue
        fi
        
        local category=$(get_category_from_url "$url")
        
        if ! check_pattern_exists_on_kiwix "$category" "$base"; then
            OLD_FILE_PROTECTED["$filename"]=1
        fi
    done
    
    printf "\r%80s\r" ""
    
    if [[ ${#OLD_FILE_PROTECTED[@]} -gt 0 ]]; then
        log_protect "Protected ${#OLD_FILE_PROTECTED[@]} orphaned files"
    fi
}

# Download functions
download_with_aria2c() {
    local url=$1
    local filename=$(basename "$url")
    
    local resume_flag=""
    [[ -f "${DOWNLOAD_DIR}/${filename}" ]] && resume_flag="--continue=true"
    
    aria2c \
        --dir="$DOWNLOAD_DIR" \
        --out="$filename" \
        --max-connection-per-server="$ARIA2C_CONNECTIONS" \
        --split="$ARIA2C_SPLIT" \
        --max-tries="$ARIA2C_MAX_TRIES" \
        --timeout="$ARIA2C_TIMEOUT" \
        --check-certificate=false \
        --auto-file-renaming=false \
        $resume_flag \
        "$url" 2>&1
}

download_with_wget() {
    local url=$1
    local filename=$(basename "$url")
    
    wget \
        -O "${DOWNLOAD_DIR}/${filename}" \
        --timeout="$WGET_TIMEOUT" \
        --tries=3 \
        --continue \
        --progress=bar:force \
        "$url" 2>&1
}

download_file() {
    local url=$1
    local filename=$(basename "$url")
    local file_path="${DOWNLOAD_DIR}/${filename}"
    
    if is_file_complete "$file_path" "$url"; then
        log_info "Already complete: ${filename}"
        STAT_SKIPPED=$((STAT_SKIPPED + 1))
        return 0
    fi
    
    log_download "Downloading: ${filename}"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY RUN] Would download: ${filename}"
        return 0
    fi
    
    local success=false
    
    if command -v aria2c &>/dev/null; then
        if download_with_aria2c "$url"; then
            success=true
        else
            log_warn "aria2c failed, trying wget..."
        fi
    fi
    
    if [[ "$success" == "false" ]] && command -v wget &>/dev/null; then
        download_with_wget "$url" && success=true
    fi
    
    if [[ "$success" == "true" ]]; then
        log_info "Downloaded: ${filename}"
        STAT_DOWNLOADED=$((STAT_DOWNLOADED + 1))
        return 0
    else
        log_error "Failed: ${filename}"
        STAT_FAILED=$((STAT_FAILED + 1))
        return 1
    fi
}

# Interactive download/delete selection
select_downloads_interactive() {
    local total_downloads=${#TO_DOWNLOAD[@]}
    local total_old=${#OLD_FILES[@]}
    
    # Initialize - all downloads selected, safe deletions selected
    for url in "${TO_DOWNLOAD[@]}"; do
        SELECTED_DOWNLOADS["$url"]=1
    done
    
    for filename in "${OLD_FILES[@]}"; do
        [[ -z "${OLD_FILE_PROTECTED[$filename]:-}" ]] && SELECTED_DELETIONS["$filename"]=1
    done
    
    [[ "$AUTO_MODE" == "true" ]] && return
    
    # Combined interactive menu
    while true; do
        clear_screen
        log_info "=== Download & Cleanup Selection ==="
        echo ""
        
        # Downloads section
        if [[ $total_downloads -gt 0 ]]; then
            log_info "Files to Download:"
            local idx=0
            for url in "${TO_DOWNLOAD[@]}"; do
                idx=$((idx + 1))
                local filename=$(basename "$url")
                local mark="[ ]"
                [[ -n "${SELECTED_DOWNLOADS[$url]:-}" ]] && mark="[X]"
                printf "  %3d) %s %s\n" "$idx" "$mark" "$filename"
            done
            echo ""
        fi
        
        # Old files section
        if [[ $total_old -gt 0 ]]; then
            log_info "Old Versions to Remove:"
            local idx=$total_downloads
            for filename in "${OLD_FILES[@]}"; do
                idx=$((idx + 1))
                local mark="[ ]"
                local suffix=""
                if [[ -n "${OLD_FILE_PROTECTED[$filename]:-}" ]]; then
                    mark="---"
                    suffix=" ${BLUE}[PROTECTED]${NC}"
                elif [[ -n "${SELECTED_DELETIONS[$filename]:-}" ]]; then
                    mark="[X]"
                fi
                printf "  %3d) %s %s%b\n" "$idx" "$mark" "$filename" "$suffix"
            done
            echo ""
        fi
        
        # Summary
        local sel_dl=0 sel_del=0
        for _ in "${!SELECTED_DOWNLOADS[@]}"; do sel_dl=$((sel_dl + 1)); done
        for _ in "${!SELECTED_DELETIONS[@]}"; do sel_del=$((sel_del + 1)); done
        
        log_info "Selected: ${sel_dl} downloads, ${sel_del} deletions"
        echo ""
        log_info "Toggle: 1,3,5 or 1-5 | all | none | Enter=proceed | q=quit"
        echo ""
        read -p "> " input
        
        [[ -z "$input" ]] && break
        [[ "$input" == "q" ]] && { log_info "Cancelled"; exit 0; }
        
        if [[ "$input" == "all" ]]; then
            for url in "${TO_DOWNLOAD[@]}"; do SELECTED_DOWNLOADS["$url"]=1; done
            continue
        fi
        if [[ "$input" == "none" ]]; then
            SELECTED_DOWNLOADS=()
            continue
        fi
        
        # Parse toggles
        local -a parts=()
        IFS=', ' read -ra parts <<< "$input"
        
        for part in "${parts[@]}"; do
            [[ -z "$part" ]] && continue
            
            local start_n end_n
            if [[ "$part" =~ ^([0-9]+)-([0-9]+)$ ]]; then
                start_n=${BASH_REMATCH[1]}
                end_n=${BASH_REMATCH[2]}
            elif [[ "$part" =~ ^[0-9]+$ ]]; then
                start_n=$((10#$part))
                end_n=$start_n
            else
                continue
            fi
            
            for ((n=start_n; n<=end_n; n++)); do
                if [[ $n -ge 1 && $n -le $total_downloads ]]; then
                    local url="${TO_DOWNLOAD[$((n-1))]}"
                    if [[ -n "${SELECTED_DOWNLOADS[$url]:-}" ]]; then
                        unset SELECTED_DOWNLOADS["$url"]
                    else
                        SELECTED_DOWNLOADS["$url"]=1
                    fi
                elif [[ $n -gt $total_downloads && $n -le $((total_downloads + total_old)) ]]; then
                    local idx=$((n - total_downloads - 1))
                    local filename="${OLD_FILES[$idx]}"
                    
                    [[ -n "${OLD_FILE_PROTECTED[$filename]:-}" ]] && continue
                    
                    if [[ -n "${SELECTED_DELETIONS[$filename]:-}" ]]; then
                        unset SELECTED_DELETIONS["$filename"]
                    else
                        SELECTED_DELETIONS["$filename"]=1
                    fi
                fi
            done
        done
    done
}

# Execute downloads
execute_downloads() {
    local count=${#SELECTED_DOWNLOADS[@]}
    [[ $count -eq 0 ]] && return
    
    log_info "Downloading ${count} files..."
    echo ""
    
    local current=0
    for url in "${!SELECTED_DOWNLOADS[@]}"; do
        current=$((current + 1))
        log_info "[${current}/${count}] $(basename "$url")"
        download_file "$url" || true
    done
}

# Execute deletions
execute_deletions() {
    [[ "$KEEP_OLD" == "true" ]] && return
    
    local count=${#SELECTED_DELETIONS[@]}
    [[ $count -eq 0 ]] && return
    
    log_info "Removing ${count} old files..."
    echo ""
    
    for filename in "${!SELECTED_DELETIONS[@]}"; do
        local file_path="${DOWNLOAD_DIR}/${filename}"
        
        if [[ "$DRY_RUN" == "true" ]]; then
            log_info "[DRY RUN] Would delete: ${filename}"
        else
            if rm -f "$file_path"; then
                log_delete "Deleted: ${filename}"
                STAT_DELETED=$((STAT_DELETED + 1))
            else
                log_error "Failed to delete: ${filename}"
            fi
        fi
    done
}

# === VERIFY Command ===

verify_files() {
    log_info "Verifying existing files..."
    echo ""
    
    local verified=0
    local incomplete=0
    
    for url in "${!URL_ENTRIES[@]}"; do
        local filename=$(basename "$url")
        local file_path="${DOWNLOAD_DIR}/${filename}"
        
        [[ ! -f "$file_path" ]] && continue
        
        printf "\r  Checking: %-50s" "$filename"
        
        if is_file_complete "$file_path" "$url"; then
            verified=$((verified + 1))
        else
            incomplete=$((incomplete + 1))
            echo ""
            log_warn "Incomplete: $filename"
        fi
    done
    
    printf "\r%80s\r" ""
    echo ""
    log_info "Verified: ${verified} complete, ${incomplete} incomplete"
}

# === Command Runners ===

run_update() {
    load_url_file
    
    if ! check_for_updates; then
        return 0
    fi
    
    # Select updates
    run_selection_menu "Select Updates to Apply" UPDATE_LIST SELECTED_UPDATES display_update_item
    
    apply_url_updates
}

run_download() {
    load_url_file
    scan_local_files
    find_downloads_and_old_files
    check_orphan_protection
    
    if [[ ${#TO_DOWNLOAD[@]} -eq 0 && ${#OLD_FILES[@]} -eq 0 ]]; then
        log_info "Everything is up to date!"
        return 0
    fi
    
    select_downloads_interactive
    execute_downloads
    execute_deletions
}

run_sync() {
    # Phase 1: Update URLs
    log_info "=== Phase 1: Updating URLs ==="
    echo ""
    run_update
    
    # Reload URL file after updates
    URL_ENTRIES=()
    URL_PATTERNS=()
    
    echo ""
    log_info "=== Phase 2: Downloading Files ==="
    echo ""
    run_download
}

run_verify() {
    load_url_file
    scan_local_files
    verify_files
}

# === Summary ===

print_summary() {
    echo ""
    log_info "=== Summary ==="
    [[ $STAT_URLS_UPDATED -gt 0 ]] && log_info "URLs updated: ${STAT_URLS_UPDATED}"
    [[ $STAT_DOWNLOADED -gt 0 ]] && log_info "Downloaded: ${STAT_DOWNLOADED}"
    [[ $STAT_SKIPPED -gt 0 ]] && log_info "Skipped (complete): ${STAT_SKIPPED}"
    [[ $STAT_FAILED -gt 0 ]] && log_warn "Failed: ${STAT_FAILED}"
    [[ $STAT_DELETED -gt 0 ]] && log_info "Deleted: ${STAT_DELETED}"
    [[ ${#OLD_FILE_PROTECTED[@]} -gt 0 ]] && log_info "Protected: ${#OLD_FILE_PROTECTED[@]}"
}

# === Main ===

main() {
    parse_args "$@"
    check_dependencies
    
    echo ""
    log_info "=== Kiwix ZIM Sync Manager ==="
    log_info "Command: ${COMMAND}"
    [[ "$DRY_RUN" == "true" ]] && log_warn "DRY RUN MODE"
    [[ "$AUTO_MODE" == "true" ]] && log_info "Running in automatic mode"
    [[ "$KEEP_OLD" == "true" ]] && log_info "Keep old versions enabled"
    echo ""
    log_info "URL file: $URL_FILE"
    [[ "$COMMAND" != "update" ]] && log_info "Download dir: $DOWNLOAD_DIR"
    echo ""
    
    case "$COMMAND" in
        update)
            run_update
            ;;
        download)
            run_download
            ;;
        sync)
            run_sync
            ;;
        verify)
            run_verify
            ;;
    esac
    
    [[ "$COMMAND" != "verify" ]] && print_summary
}

main "$@"
