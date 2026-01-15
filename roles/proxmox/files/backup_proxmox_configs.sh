#!/bin/bash
#
# Proxmox VM/LXC Configuration Backup Script
# This script copies VM and LXC configurations from a source Proxmox server
# to the local files directory for use with the almir.proxmox Ansible role
#
# Usage: ./backup_proxmox_configs.sh [source_server]
# Example: ./backup_proxmox_configs.sh root@192.168.50.130
#
# The script will:
# - Copy all VM configs from /etc/pve/qemu-server/*.conf
# - Copy all LXC configs from /etc/pve/lxc/*.conf
# - Store them in files/vm_configs/ and files/lxc_configs/ directories
#

set -euo pipefail

# Default source server (can be overridden via command line argument)
SOURCE_SERVER="${1:-root@x.x.x.x}"
SSH_KEY="${SSH_KEY:-$HOME/.ssh/id_rsa}"

# Script directory (where this script is located)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROLE_DIR="$(dirname "$SCRIPT_DIR")"
VM_CONFIG_DIR="${ROLE_DIR}/files/vm_configs"
LXC_CONFIG_DIR="${ROLE_DIR}/files/lxc_configs"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if SSH key exists
if [ ! -f "$SSH_KEY" ]; then
    log_error "SSH key not found at: $SSH_KEY"
    log_info "Set SSH_KEY environment variable to specify key location"
    exit 1
fi

# Test SSH connection
log_info "Testing SSH connection to $SOURCE_SERVER..."
if ! ssh -i "$SSH_KEY" -o ConnectTimeout=5 -o StrictHostKeyChecking=no "$SOURCE_SERVER" "echo 'Connection successful'" >/dev/null 2>&1; then
    log_error "Failed to connect to $SOURCE_SERVER"
    log_info "Please verify:"
    log_info "  - Server is reachable"
    log_info "  - SSH key is correct: $SSH_KEY"
    log_info "  - User has access to /etc/pve/ directory"
    exit 1
fi

log_info "SSH connection successful"

# Create directories if they don't exist
mkdir -p "$VM_CONFIG_DIR"
mkdir -p "$LXC_CONFIG_DIR"

# Backup VM configurations
log_info "Backing up VM configurations from $SOURCE_SERVER..."
VM_COUNT=$(ssh -i "$SSH_KEY" "$SOURCE_SERVER" "ls -1 /etc/pve/qemu-server/*.conf 2>/dev/null | wc -l" || echo "0")

if [ "$VM_COUNT" -gt 0 ]; then
    # Create a temporary directory on remote server
    TEMP_DIR=$(ssh -i "$SSH_KEY" "$SOURCE_SERVER" "mktemp -d")
    
    # Copy all VM configs to temp directory
    ssh -i "$SSH_KEY" "$SOURCE_SERVER" "cp /etc/pve/qemu-server/*.conf $TEMP_DIR/ 2>/dev/null || true"
    
    # Copy from temp directory to local
    scp -i "$SSH_KEY" "$SOURCE_SERVER:$TEMP_DIR/*.conf" "$VM_CONFIG_DIR/" 2>/dev/null || true
    
    # Cleanup temp directory
    ssh -i "$SSH_KEY" "$SOURCE_SERVER" "rm -rf $TEMP_DIR"
    
    log_info "Copied $VM_COUNT VM configuration(s) to $VM_CONFIG_DIR"
else
    log_warn "No VM configurations found on source server"
fi

# Backup LXC configurations
log_info "Backing up LXC configurations from $SOURCE_SERVER..."
LXC_COUNT=$(ssh -i "$SSH_KEY" "$SOURCE_SERVER" "ls -1 /etc/pve/lxc/*.conf 2>/dev/null | wc -l" || echo "0")

if [ "$LXC_COUNT" -gt 0 ]; then
    # Create a temporary directory on remote server
    TEMP_DIR=$(ssh -i "$SSH_KEY" "$SOURCE_SERVER" "mktemp -d")
    
    # Copy all LXC configs to temp directory
    ssh -i "$SSH_KEY" "$SOURCE_SERVER" "cp /etc/pve/lxc/*.conf $TEMP_DIR/ 2>/dev/null || true"
    
    # Copy from temp directory to local
    scp -i "$SSH_KEY" "$SOURCE_SERVER:$TEMP_DIR/*.conf" "$LXC_CONFIG_DIR/" 2>/dev/null || true
    
    # Cleanup temp directory
    ssh -i "$SSH_KEY" "$SOURCE_SERVER" "rm -rf $TEMP_DIR"
    
    log_info "Copied $LXC_COUNT LXC configuration(s) to $LXC_CONFIG_DIR"
else
    log_warn "No LXC configurations found on source server"
fi

# Create a task file to deploy these configs (optional - for reference)
log_info "Backup completed successfully!"
log_info "VM configs: $VM_CONFIG_DIR"
log_info "LXC configs: $LXC_CONFIG_DIR"
log_info ""
log_info "To deploy these configs to a new Proxmox server, you can:"
log_info "  1. Copy the configs to /etc/pve/qemu-server/ and /etc/pve/lxc/ on the target server"
log_info "  2. Ensure the storage pools and disks are imported first"
log_info "  3. Restart the pve-cluster service if needed"

