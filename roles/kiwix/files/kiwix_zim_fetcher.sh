#!/bin/bash
#
# Kiwix ZIM File URL Fetcher
# Generates a list of ZIM file URLs from https://download.kiwix.org/zim/
#
# Usage: ./kiwix_zim_fetcher.sh
#

set -euo pipefail

# === Configuration ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_DOWNLOAD_DIR="${SCRIPT_DIR}/zim_files"
DEFAULT_URL_FILE="${SCRIPT_DIR}/zim_files/zim_urls.txt"
KIWIX_BASE_URL="https://download.kiwix.org/zim"

# === Global State ===
declare -a SELECTED_CATEGORIES=()
declare -a IMPORTED_URLS=()
declare -a IMPORTED_INVALID_URLS=()
declare -a SELECTED_LANGUAGES=()
declare -a FILE_TYPES=()
declare -A SELECTED_FILES_BY_CATEGORY=()

URL_FILE=""
DOWNLOAD_DIR=""
ACTION_CHOICE=""
IMPORT_PREVIOUS="false"
INCLUDE_NO_LANG="true"
INCLUDE_NO_VARIANT="true"
SELECT_LATEST_ONLY="true"

# === Logging Functions ===
log_info()  { echo -e "${GREEN}[INFO]${NC} $1" >&2; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1" >&2; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }
log_debug() { [[ "${DEBUG:-}" == "1" ]] && echo -e "${BLUE}[DEBUG]${NC} $1" >&2 || true; }

clear_screen() { [[ -t 1 ]] && clear 2>/dev/null || true; }

# === Utility Functions ===
check_dependencies() {
    if ! command -v curl &>/dev/null; then
        log_error "Missing required dependency: curl"
        exit 1
    fi
}

format_file_size() {
    local size_bytes=$1
    [[ -z "$size_bytes" || "$size_bytes" == "0" ]] && { echo "unknown"; return; }
    
    local size_gb=$(awk "BEGIN {printf \"%.2f\", $size_bytes / 1073741824}")
    if awk "BEGIN {exit !($size_gb < 1.0)}"; then
        awk "BEGIN {printf \"%.1fMB\", $size_bytes / 1048576}"
    else
        echo "${size_gb}GB"
    fi
}

# === Network Functions ===
fetch_categories() {
    log_info "Fetching categories from ${KIWIX_BASE_URL}..."
    curl -s "${KIWIX_BASE_URL}/" | \
        grep -oP 'href="([^"]+)/"' | \
        sed 's/href="//;s/\/"//' | \
        grep -vE '^(Parent|README|\.\.?|index|\.html?|http|https)$' | \
        grep -vE '^[0-9A-Z]' | \
        grep -E '^[a-z_]+$' | \
        sort -u
}

# Quick count of files in a category (returns count)
count_category_files() {
    local category=$1
    curl -s "${KIWIX_BASE_URL}/${category}/" 2>/dev/null | grep -c '\.zim"' || echo "0"
}

# Get unique language prefixes from a category
get_category_languages() {
    local category=$1
    curl -s "${KIWIX_BASE_URL}/${category}/" 2>/dev/null | \
        grep -oP 'href="[^"]+\.zim"' | \
        sed 's/href="//;s/"//' | \
        sed -n 's/^[^_]*_\([a-z]\{2,3\}\)_.*/\1/p' | \
        sort -u
}

fetch_zim_files_with_sizes() {
    local category=$1
    local lang_filter="${2:-}"  # Optional language filter
    
    log_debug "Fetching ZIM files from: ${category}"
    
    curl -s "${KIWIX_BASE_URL}/${category}/" | grep '\.zim' | while IFS= read -r line; do
        local filename=$(echo "$line" | grep -oP 'href="([^"]+\.zim)"' | sed 's/href="//;s/"//')
        [[ -z "$filename" ]] && continue
        
        # Apply language filter if specified
        if [[ -n "$lang_filter" ]]; then
            local file_lang=$(echo "$filename" | sed -n 's/^[^_]*_\([a-z]\{2,3\}\)_.*/\1/p')
            [[ "$file_lang" != "$lang_filter" ]] && continue
        fi
        
        # Extract size (format: YYYY-MM-DD HH:MM SIZE)
        local size_str=$(echo "$line" | sed -n 's/.*[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}\s\+[0-9]\{2\}:[0-9]\{2\}\s\+\([0-9.]\+[GMK]\?\).*/\1/p' | tr -d ' ')
        [[ -z "$size_str" ]] && size_str=$(echo "$line" | awk '{for(i=NF;i>0;i--) if($i ~ /^[0-9.]+[GMK]?$/) {print $i; break}}')
        
        # Convert to bytes
        local size_bytes=0
        if [[ "$size_str" =~ ^([0-9.]+)G$ ]]; then
            size_bytes=$(awk "BEGIN {printf \"%.0f\", ${BASH_REMATCH[1]} * 1073741824}")
        elif [[ "$size_str" =~ ^([0-9.]+)M$ ]]; then
            size_bytes=$(awk "BEGIN {printf \"%.0f\", ${BASH_REMATCH[1]} * 1048576}")
        elif [[ "$size_str" =~ ^([0-9.]+)K$ ]]; then
            size_bytes=$(awk "BEGIN {printf \"%.0f\", ${BASH_REMATCH[1]} * 1024}")
        elif [[ "$size_str" =~ ^([0-9.]+)$ ]]; then
            size_bytes="${BASH_REMATCH[1]}"
        fi
        
        echo "${KIWIX_BASE_URL}/${category}/${filename}|${size_bytes}"
    done
}

check_url_exists() {
    local url=$1
    local http_code=$(curl -s -o /dev/null -w "%{http_code}" --head --max-time 10 "$url" 2>/dev/null)
    [[ "$http_code" =~ ^(200|301|302|303|307|308)$ ]]
}

# === File Parsing Functions ===
parse_filename() {
    local filename=$1
    local basename="${filename%.zim}"
    
    local date="" variant="" lang=""
    
    # Extract date (YYYY-MM at end)
    if [[ $basename =~ ([0-9]{4}-[0-9]{2})$ ]]; then
        date="${BASH_REMATCH[1]}"
        basename="${basename%_${date}}"
    fi
    
    # Extract variant
    if [[ $basename =~ _nopic$ ]]; then
        variant="nopic"
        basename="${basename%_nopic}"
    elif [[ $basename =~ _maxi$ ]]; then
        variant="maxi"
        basename="${basename%_maxi}"
    fi
    
    # Extract language (2-3 letter code at end)
    if [[ $basename =~ _([a-z]{2,3})(_all)?$ ]]; then
        lang="${BASH_REMATCH[1]}"
    fi
    
    echo "${lang}|${date}|${variant}"
}

matches_language_preferences() {
    local url=$1
    local parsed=$(parse_filename "$(basename "$url")")
    local lang=$(echo "$parsed" | cut -d'|' -f1)
    
    [[ "${SELECTED_LANGUAGES[0]}" == "all" ]] && return 0
    [[ -z "$lang" ]] && { [[ "$INCLUDE_NO_LANG" == "true" ]] && return 0 || return 1; }
    
    for selected_lang in "${SELECTED_LANGUAGES[@]}"; do
        [[ "$lang" == "$selected_lang" ]] && return 0
    done
    return 1
}

matches_file_type_preferences() {
    local url=$1
    local parsed=$(parse_filename "$(basename "$url")")
    local variant=$(echo "$parsed" | cut -d'|' -f3)
    
    for file_type in "${FILE_TYPES[@]}"; do
        [[ "$file_type" == "all" ]] && return 0
    done
    
    [[ -z "$variant" ]] && { [[ "$INCLUDE_NO_VARIANT" == "true" ]] && return 0 || return 1; }
    
    for file_type in "${FILE_TYPES[@]}"; do
        [[ "$variant" == "$file_type" ]] && return 0
    done
    return 1
}

get_latest_files() {
    local urls=("$@")
    declare -A latest_files
    declare -A latest_dates
    
    for url in "${urls[@]}"; do
        local filename=$(basename "$url")
        local parsed=$(parse_filename "$filename")
        local date=$(echo "$parsed" | cut -d'|' -f2)
        
        # Create pattern key (filename without date)
        local pattern_key="${filename%_${date}.zim}"
        
        if [[ -z "${latest_dates[$pattern_key]:-}" ]] || [[ "$date" > "${latest_dates[$pattern_key]}" ]]; then
            latest_files[$pattern_key]="$url"
            latest_dates[$pattern_key]="$date"
        fi
    done
    
    printf '%s\n' "${latest_files[@]}"
}

# === Selection Menu Functions ===
select_categories() {
    local categories=("$@")
    
    clear_screen
    log_info "=== Category Selection ==="
    echo ""
    log_info "Available categories:"
    echo ""
    
    for i in "${!categories[@]}"; do
        printf "  %2d) %s\n" $((i+1)) "${categories[$i]}"
    done
    
    echo ""
    log_info "Enter numbers (e.g., 1,3,5), ranges (1-5), or 'all'"
    echo ""
    read -p "Selection: " category_selection
    
    if [[ "$category_selection" == "all" ]]; then
        SELECTED_CATEGORIES=("${categories[@]}")
        return
    fi
    
    local -a selected_indices=()
    IFS=',' read -ra selections <<< "$category_selection"
    
    for sel in "${selections[@]}"; do
        sel=$(echo "$sel" | tr -d '[:space:]')
        
        if [[ "$sel" =~ ^([0-9]+)-([0-9]+)$ ]]; then
            for ((idx=${BASH_REMATCH[1]}; idx<=${BASH_REMATCH[2]}; idx++)); do
                ((idx >= 1 && idx <= ${#categories[@]})) && selected_indices+=($((idx-1)))
            done
        elif [[ "$sel" =~ ^[0-9]+$ ]]; then
            ((sel >= 1 && sel <= ${#categories[@]})) && selected_indices+=($((sel-1)))
        fi
    done
    
    # Remove duplicates
    IFS=$'\n' selected_indices=($(printf "%s\n" "${selected_indices[@]}" | sort -un))
    
    SELECTED_CATEGORIES=()
    for idx in "${selected_indices[@]}"; do
        SELECTED_CATEGORIES+=("${categories[$idx]}")
    done
    
    if [[ ${#SELECTED_CATEGORIES[@]} -eq 0 ]]; then
        log_error "No valid categories selected!"
        exit 1
    fi
    
    echo ""
    log_info "Selected ${#SELECTED_CATEGORIES[@]} categories"
}

select_files_interactive() {
    local category=$1
    shift
    local -a all_files=()
    local -a all_sizes=()
    
    # Parse input (URL|SIZE format)
    while [[ $# -gt 0 ]]; do
        local entry=$1
        shift
        all_files+=("${entry%|*}")
        all_sizes+=("${entry##*|}")
    done
    
    local file_count=${#all_files[@]}
    [[ $file_count -eq 0 ]] && return
    
    # Selection state file: one line per file, "0" or "1"
    local state_file=$(mktemp)
    trap "rm -f '$state_file'" RETURN
    
    # Auto-select based on preferences
    log_info "Auto-selecting files based on preferences..."
    local -a auto_match=()
    
    for i in "${!all_files[@]}"; do
        if matches_file_type_preferences "${all_files[$i]}" && matches_language_preferences "${all_files[$i]}"; then
            auto_match+=("${all_files[$i]}")
        fi
    done
    
    # Filter to latest only
    if [[ "$SELECT_LATEST_ONLY" == "true" ]] && [[ ${#auto_match[@]} -gt 0 ]]; then
        local latest=$(get_latest_files "${auto_match[@]}")
        auto_match=()
        while IFS= read -r u; do
            [[ -n "$u" ]] && auto_match+=("$u")
        done <<< "$latest"
    fi
    
    # Initialize state file: 0 or 1 for each file
    for i in "${!all_files[@]}"; do
        local sel=0
        for m in "${auto_match[@]}"; do
            [[ "${all_files[$i]}" == "$m" ]] && { sel=1; break; }
        done
        echo "$sel" >> "$state_file"
    done
    
    log_info "Auto-selected ${#auto_match[@]} files"
    sleep 1
    
    # Main loop
    while true; do
        clear_screen
        log_info "=== File Selection: ${category} ==="
        echo ""
        
        # Read current state into array
        local -a state=()
        while IFS= read -r line; do
            state+=("$line")
        done < "$state_file"
        
        # Display
        local sel_count=0
        local total_bytes=0
        for i in "${!all_files[@]}"; do
            local mark="[ ]"
            if [[ "${state[$i]}" == "1" ]]; then
                mark="[X]"
                sel_count=$((sel_count + 1))
                [[ "${all_sizes[$i]}" != "0" ]] && total_bytes=$((total_bytes + all_sizes[$i]))
            fi
            local sz=$(format_file_size "${all_sizes[$i]}")
            printf "  %3d) %s %-55s %8s\n" "$((i+1))" "$mark" "$(basename "${all_files[$i]}")" "$sz"
        done
        
        echo ""
        log_info "Selected: ${sel_count}/${file_count} ($(format_file_size $total_bytes))"
        echo ""
        log_info "Toggle: 1,3,5 or 1-5 | all | none | Enter=done"
        echo ""
        read -p "> " input
        
        [[ -z "$input" ]] && break
        
        # Handle all/none
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
        
        # Parse numbers and ranges, toggle immediately
        # First, replace commas with spaces and split into array
        local -a parts=()
        IFS=', ' read -ra parts <<< "$input"
        
        for part in "${parts[@]}"; do
            [[ -z "$part" ]] && continue
            
            if [[ "$part" =~ ^([0-9]+)-([0-9]+)$ ]]; then
                # Range like 4-5
                local start_n=${BASH_REMATCH[1]}
                local end_n=${BASH_REMATCH[2]}
                local n
                for ((n=start_n; n<=end_n; n++)); do
                    if [[ $n -ge 1 && $n -le $file_count ]]; then
                        local idx=$((n - 1))
                        [[ "${state[$idx]}" == "1" ]] && state[$idx]=0 || state[$idx]=1
                    fi
                done
            elif [[ "$part" =~ ^[0-9]+$ ]]; then
                # Single number
                local n=$((10#$part))
                if [[ $n -ge 1 && $n -le $file_count ]]; then
                    local idx=$((n - 1))
                    [[ "${state[$idx]}" == "1" ]] && state[$idx]=0 || state[$idx]=1
                fi
            fi
        done
        
        # Write state back
        printf '%s\n' "${state[@]}" > "$state_file"
    done
    
    # Build final list
    local -a state=()
    while IFS= read -r line; do
        state+=("$line")
    done < "$state_file"
    
    local result=""
    for i in "${!all_files[@]}"; do
        [[ "${state[$i]}" == "1" ]] && result="$result${all_files[$i]}"$'\n'
    done
    
    SELECTED_FILES_BY_CATEGORY["$category"]="${result%$'\n'}"
    
    local final_count=0
    for s in "${state[@]}"; do [[ "$s" == "1" ]] && final_count=$((final_count + 1)); done
    log_info "Final: ${final_count} files for '${category}'"
    sleep 1
}

get_file_type_preferences() {
    clear_screen
    log_info "=== File Type Selection ==="
    echo ""
    log_info "Available: all, maxi, nopic"
    echo ""
    read -p "File types [maxi]: " input
    input=${input:-maxi}
    
    IFS=',' read -ra FILE_TYPES <<< "$input"
    for i in "${!FILE_TYPES[@]}"; do
        FILE_TYPES[$i]=$(echo "${FILE_TYPES[$i]}" | tr -d '[:space:]')
    done
    
    # Check if specific types selected (not "all")
    local has_specific=false
    for ft in "${FILE_TYPES[@]}"; do
        [[ "$ft" != "all" ]] && has_specific=true
    done
    
    if [[ "$has_specific" == "true" ]]; then
        echo ""
        read -p "Include files without these parameters? (y/n) [y]: " include
        INCLUDE_NO_VARIANT=$([[ "${include:-y}" == "y" ]] && echo "true" || echo "false")
    else
        INCLUDE_NO_VARIANT="true"
    fi
    
    echo ""
    log_info "Selected: ${FILE_TYPES[*]}"
}

get_language_preferences() {
    clear_screen
    log_info "=== Language Selection ==="
    echo ""
    log_info "Examples: 'en', 'en,de,fr', 'all'"
    echo ""
    read -p "Languages [en]: " input
    input=${input:-en}
    
    if [[ "$input" == "all" ]]; then
        SELECTED_LANGUAGES=("all")
        INCLUDE_NO_LANG="true"
    else
        IFS=',' read -ra SELECTED_LANGUAGES <<< "$input"
        for i in "${!SELECTED_LANGUAGES[@]}"; do
            SELECTED_LANGUAGES[$i]=$(echo "${SELECTED_LANGUAGES[$i]}" | tr -d '[:space:]')
        done
        
        echo ""
        read -p "Include files without language codes? (y/n) [y]: " include
        INCLUDE_NO_LANG=$([[ "${include:-y}" == "y" ]] && echo "true" || echo "false")
    fi
    
    echo ""
    log_info "Selected: ${SELECTED_LANGUAGES[*]}"
}

get_version_preference() {
    clear_screen
    log_info "=== Version Selection ==="
    echo ""
    log_info "  a) Latest only (recommended)"
    log_info "  b) All versions"
    echo ""
    read -p "Choice [a]: " choice
    
    SELECT_LATEST_ONLY=$([[ "${choice:-a}" == "b" ]] && echo "false" || echo "true")
    log_info "Selected: $([[ "$SELECT_LATEST_ONLY" == "true" ]] && echo "latest only" || echo "all versions")"
}

validate_imported_urls() {
    local urls=("$@")
    local -a valid_urls=()
    local -a invalid_urls=()
    local total=${#urls[@]}
    
    [[ $total -eq 0 ]] && return 0
    
    log_info "Validating ${total} imported URLs..."
    
    local checked=0
    for url in "${urls[@]}"; do
        checked=$((checked + 1))
        printf "\r  [%3d/%3d] Checking..." "$checked" "$total" >&2
        
        if check_url_exists "$url"; then
            valid_urls+=("$url")
        else
            invalid_urls+=("$url")
        fi
    done
    printf "\r%60s\r" "" >&2
    
    if [[ ${#invalid_urls[@]} -gt 0 ]]; then
        log_warn "Found ${#invalid_urls[@]} URLs no longer available:"
        for url in "${invalid_urls[@]}"; do
            echo "    - $(basename "$url")" >&2
        done
        echo ""
    fi
    
    IMPORTED_URLS=("${valid_urls[@]}")
    IMPORTED_INVALID_URLS=("${invalid_urls[@]}")
    
    log_info "Valid: ${#valid_urls[@]}, Invalid: ${#invalid_urls[@]}"
    [[ ${#valid_urls[@]} -gt 0 ]]
}

import_previous_urls() {
    local url_file=$1
    [[ ! -f "$url_file" ]] && return 1
    
    local -a imported=()
    while IFS= read -r url; do
        # Skip empty lines and comments
        [[ -z "$url" || "$url" == \#* ]] && continue
        [[ "$url" =~ ^https?:// ]] && imported+=("$url")
    done < "$url_file"
    
    [[ ${#imported[@]} -eq 0 ]] && return 1
    
    validate_imported_urls "${imported[@]}"
}

interactive_menu() {
    clear_screen
    log_info "=== Kiwix ZIM File Fetcher ==="
    echo ""
    
    read -p "URL file location [${DEFAULT_URL_FILE}]: " url_file
    URL_FILE=${url_file:-$DEFAULT_URL_FILE}
    clear_screen
    
    # Check existing file
    if [[ -f "$URL_FILE" ]]; then
        local line_count=$(wc -l < "$URL_FILE" 2>/dev/null || echo "0")
        if [[ $line_count -gt 0 ]]; then
            log_info "Existing file found: ${URL_FILE} (${line_count} URLs)"
            echo ""
            log_info "  a) Recreate - Start fresh"
            log_info "  b) Import - Load and update existing (recommended)"
            echo ""
            read -p "Choice [b]: " import_choice
            clear_screen
            
            if [[ "${import_choice:-b}" == "b" ]]; then
                IMPORT_PREVIOUS="true"
                if import_previous_urls "$URL_FILE"; then
                    log_info "Imported ${#IMPORTED_URLS[@]} valid URLs"
                else
                    log_warn "Import failed, starting fresh"
                    IMPORT_PREVIOUS="false"
                fi
            fi
        fi
    fi
    
    echo ""
    read -p "Download location [${DEFAULT_DOWNLOAD_DIR}]: " download_dir
    DOWNLOAD_DIR=${download_dir:-$DEFAULT_DOWNLOAD_DIR}
    clear_screen
    
    echo ""
    log_info "Action:"
    log_info "  a) Generate URL list only"
    log_info "  b) Generate and download"
    read -p "Choice [a]: " action
    ACTION_CHOICE=${action:-a}
    clear_screen
}

# === Main ===
main() {
    check_dependencies
    interactive_menu
    
    mkdir -p "$(dirname "$URL_FILE")" "$DOWNLOAD_DIR"
    
    # Fetch categories
    local categories_output=$(fetch_categories)
    local -a category_array=($categories_output)
    
    if [[ ${#category_array[@]} -eq 0 ]]; then
        log_error "No categories found!"
        exit 1
    fi
    
    log_info "Found ${#category_array[@]} categories"
    
    # Selection stages
    select_categories "${category_array[@]}"
    get_file_type_preferences
    get_language_preferences
    get_version_preference
    
    # Process each category
    for category in "${SELECTED_CATEGORIES[@]}"; do
        log_info "Processing: ${category}"
        
        # Quick count to check if category is large
        local file_count=$(count_category_files "$category")
        local lang_filter=""
        
        if [[ $file_count -gt 100 ]]; then
            clear_screen
            log_warn "Category '${category}' has ${file_count} files!"
            echo ""
            log_info "Available languages in this category:"
            
            # Get and display available languages
            local -a available_langs=()
            while IFS= read -r lang; do
                [[ -n "$lang" ]] && available_langs+=("$lang")
            done < <(get_category_languages "$category")
            
            # Display in columns
            local col=0
            for lang in "${available_langs[@]}"; do
                printf "  %-6s" "$lang"
                col=$((col + 1))
                [[ $((col % 10)) -eq 0 ]] && echo ""
            done
            [[ $((col % 10)) -ne 0 ]] && echo ""
            
            echo ""
            log_info "Filter by language to reduce list, or press Enter to load all"
            log_info "(Your language preference '${SELECTED_LANGUAGES[*]}' will still apply)"
            echo ""
            read -p "Language filter (e.g., 'en') or Enter for all: " lang_filter
            
            if [[ -n "$lang_filter" ]]; then
                log_info "Filtering by language: ${lang_filter}"
            fi
        fi
        
        local -a file_data=()
        while IFS= read -r line; do
            [[ -n "$line" ]] && file_data+=("$line")
        done < <(fetch_zim_files_with_sizes "$category" "$lang_filter")
        
        if [[ ${#file_data[@]} -eq 0 ]]; then
            log_warn "No files in: ${category}"
            continue
        fi
        
        log_info "Found ${#file_data[@]} files to select from"
        
        select_files_interactive "$category" "${file_data[@]}"
    done
    
    # Build categorized URL list for writing
    declare -A categorized_urls=()
    
    for category in "${SELECTED_CATEGORIES[@]}"; do
        local selected="${SELECTED_FILES_BY_CATEGORY[$category]:-}"
        [[ -n "$selected" ]] && categorized_urls["$category"]="$selected"
    done
    
    # Add imported URLs (group by category)
    if [[ "$IMPORT_PREVIOUS" == "true" && ${#IMPORTED_URLS[@]} -gt 0 ]]; then
        log_info "Merging ${#IMPORTED_URLS[@]} imported URLs..."
        
        for url in "${IMPORTED_URLS[@]}"; do
            # Extract category from URL
            local url_category=$(echo "$url" | sed -n 's|.*/zim/\([^/]*\)/.*|\1|p')
            [[ -z "$url_category" ]] && url_category="other"
            
            # Check if duplicate
            local is_dup=false
            local existing="${categorized_urls[$url_category]:-}"
            if [[ -n "$existing" ]]; then
                while IFS= read -r existing_url; do
                    [[ "$url" == "$existing_url" ]] && { is_dup=true; break; }
                done <<< "$existing"
            fi
            
            if [[ "$is_dup" == "false" ]]; then
                if [[ -n "${categorized_urls[$url_category]:-}" ]]; then
                    categorized_urls["$url_category"]="${categorized_urls[$url_category]}"$'\n'"$url"
                else
                    categorized_urls["$url_category"]="$url"
                fi
            fi
        done
    fi
    
    # Write output with category headers
    local temp_file="${URL_FILE}.tmp"
    local total=0
    > "$temp_file"
    
    # Get sorted list of categories
    local -a sorted_categories=($(printf '%s\n' "${!categorized_urls[@]}" | sort))
    
    for category in "${sorted_categories[@]}"; do
        local urls="${categorized_urls[$category]}"
        [[ -z "$urls" ]] && continue
        
        # Write category header
        echo "" >> "$temp_file"
        echo "# ${category}" >> "$temp_file"
        
        # Write URLs
        while IFS= read -r url; do
            [[ -n "$url" ]] && { echo "$url" >> "$temp_file"; total=$((total + 1)); }
        done <<< "$urls"
    done
    
    # Remove leading empty line
    sed -i '1{/^$/d}' "$temp_file"
    
    log_info "Total URLs: ${total}"
    
    # Handle file replacement
    if [[ -f "$URL_FILE" && "$IMPORT_PREVIOUS" == "true" ]]; then
        # Check for newer versions
        local -a replacements=()
        declare -A old_map
        
        # Read old URLs, skipping comments and empty lines
        while IFS= read -r old_url; do
            [[ -z "$old_url" || "$old_url" == \#* ]] && continue
            old_map["$(basename "$old_url")"]="$old_url"
        done < "$URL_FILE"
        
        # Check all new URLs against old ones
        for category in "${!categorized_urls[@]}"; do
            local urls="${categorized_urls[$category]}"
            while IFS= read -r new_url; do
                [[ -z "$new_url" ]] && continue
                local new_file=$(basename "$new_url")
                local old_url="${old_map[$new_file]:-}"
                
                if [[ -n "$old_url" && "$old_url" != "$new_url" ]]; then
                    local old_date=$(echo "$old_url" | grep -oP '[0-9]{4}-[0-9]{2}' | tail -1)
                    local new_date=$(echo "$new_url" | grep -oP '[0-9]{4}-[0-9]{2}' | tail -1)
                    
                    [[ -n "$old_date" && -n "$new_date" && "$new_date" > "$old_date" ]] && \
                        replacements+=("${old_date} → ${new_date}: $new_file")
                fi
            done <<< "$urls"
        done
        
        if [[ ${#replacements[@]} -gt 0 ]]; then
            clear_screen
            log_info "=== Updates Found ==="
            echo ""
            log_info "${#replacements[@]} newer version(s):"
            for r in "${replacements[@]}"; do
                echo "  $r" >&2
            done
            echo ""
            log_info "  a) Replace old file"
            log_info "  b) Keep both (new name)"
            log_info "  c) Cancel"
            echo ""
            read -p "Choice [a]: " replace_choice
            
            case "${replace_choice:-a}" in
                b)
                    local new_name="${URL_FILE}.new.$(date +%Y%m%d_%H%M%S)"
                    mv "$temp_file" "$new_name"
                    log_info "Saved as: ${new_name}"
                    return
                    ;;
                c)
                    rm -f "$temp_file"
                    log_info "Cancelled"
                    return
                    ;;
            esac
        fi
    fi
    
    mv "$temp_file" "$URL_FILE"
    log_info "Saved: ${URL_FILE}"
    
    # Download if requested
    if [[ "$ACTION_CHOICE" == "b" ]]; then
        log_info "To download: ./kiwix_zim_downloader.sh ${URL_FILE} ${DOWNLOAD_DIR}"
    fi
}

main "$@"
