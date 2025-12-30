<img src="https://www.proxmox.com/images/proxmox/Proxmox_logo_standard_hex_400px.png#joomlaImage://local-images/proxmox/Proxmox_logo_standard_hex_400px.png" width="500" height="70" alt="Proxmox Logo" />


# Ansible Role - Proxmox VE Configuration

A comprehensive Ansible role for configuring and optimizing Proxmox Virtual Environment (PVE) servers. This role handles repository configuration, system tuning, ZFS optimization, GPU passthrough, backup configuration, and more.

## Features

This role provides comprehensive configuration management for Proxmox VE servers:

### 🔧 Repository & Package Management
- Configure Proxmox VE repositories (no-subscription or enterprise)
- Install microcode updates (Intel/AMD)
- Install essential system packages
- Manage Debian base repositories

### ⚡ System Tuning
- **CPU Governor**: Configure CPU frequency scaling (performance, powersave, etc.)
- **KSM (Kernel Same-page Merging)**: Automatic memory deduplication with RAM-based tuning
- **KSM Tuning**: Dynamic KSM parameters based on system RAM size

### 💾 ZFS Optimization
- **ARC Tuning**: Automatic ZFS ARC cache sizing based on RAM (min: RAM/16, max: RAM/8)
- **ZFS Scrub Schedule**: Configurable monthly scrub schedule (default: second Sunday)
- **ZFS Auto-snapshot**: Configure snapshot retention policies

### 🎮 GPU Passthrough
- **IOMMU Configuration**: Enable Intel/AMD IOMMU for GPU passthrough
- **VFIO Modules**: Automatic VFIO kernel module configuration
- **GRUB Configuration**: Add required kernel parameters for passthrough

### 💾 Backup Configuration
- **VZDump Settings**: Configure backup temporary directory, bandwidth limits, and I/O priority
- **Backup Scripts**: Optional pre/post backup scripts

### 🚫 Subscription Management
- **Nag Removal**: Remove subscription warning from Proxmox web interface
- **APT Configuration**: Prevent subscription prompts during package updates

### 🐍 Python Package Management
- **UV Installation**: Install and configure `uv` (fast Python package manager)
- **Auto-updates**: Weekly cron job for `uv` self-updates

### 📦 ISO & Template Management
- **ISO Downloads**: Download and manage ISO images
- **LXC Templates**: Download and manage LXC container templates
- **Cleanup**: Remove old ISOs and templates

### 🖥️ VM/LXC Configuration Deployment
- **Config Backup/Restore**: Deploy VM and LXC configurations from backup
- **Migration Support**: Restore configurations on new Proxmox servers

## Requirements

### Ansible Version Compatibility

This role is tested and supported with:
- **Ansible**: `>= 2.9`
- **Python**: `>= 3.6` (on target system)

### Target System Requirements

- **OS**: Proxmox VE 7.x or 8.x (Debian-based)
- **Architecture**: x86_64 (amd64)
- **Access**: SSH access with root or sudo privileges
- **Python**: Python 3 installed on target system

### Optional Requirements

- **ZFS**: For ZFS tuning features (automatically detected)
- **GPU**: For GPU passthrough features (requires IOMMU support)

## Installation

This role is part of the `brcak_zmaj.almir_ansible` collection. Install the collection:

```bash
ansible-galaxy collection install brcak_zmaj.almir_ansible
```

## Role Variables

### Repository Configuration

| Variable Name | Description | Default Value |
|---------------|-------------|---------------|
| `pve_repo_type` | Proxmox repository type (`no-subscription` or `enterprise`) | `no-subscription` |
| `pve_install_ucode` | Install microcode updates | `true` |
| `pve_reboot_for_ucode` | Reboot after microcode installation | `false` |

### CPU Configuration

| Variable Name | Description | Default Value |
|---------------|-------------|---------------|
| `pve_set_cpu` | Enable CPU governor configuration | `no` |
| `pve_cpu_governor` | CPU governor mode (`performance`, `powersave`, `ondemand`, `conservative`) | `performance` |

### ZFS Configuration

| Variable Name | Description | Default Value |
|---------------|-------------|---------------|
| `pve_zfs_scrub_enable` | Enable ZFS scrub schedule | `true` |
| `pve_zfs_scrub_minute` | Scrub minute (0-59) | `24` |
| `pve_zfs_scrub_hour` | Scrub hour (0-23) | `0` (midnight) |
| `pve_zfs_scrub_day_start` | Scrub day range start (1-31) | `8` (second week) |
| `pve_zfs_scrub_day_end` | Scrub day range end (1-31) | `14` (second week) |

**Note:** ZFS ARC min/max values are automatically calculated based on RAM size:
- **Min ARC**: RAM / 16 (minimum 512MB)
- **Max ARC**: RAM / 8 (minimum 512MB)

### GPU Passthrough Configuration

| Variable Name | Description | Default Value |
|---------------|-------------|---------------|
| `pve_gpu_passthrough_enable` | Enable GPU passthrough configuration | `true` |
| `pve_iommu_grub_params` | List of GRUB kernel parameters for IOMMU | See defaults |

**Default IOMMU Parameters:**
```yaml
pve_iommu_grub_params:
  - "intel_iommu=on"              # Enable Intel IOMMU
  - "iommu=pt"                    # Pass-through mode
  - "pcie_acs_override=downstream,multifunction"
  - "nofb"                        # Disable framebuffer
  - "nomodeset"                   # Disable kernel mode setting
  - "video=vesafb:off,efifb:off"  # Disable VESA and EFI framebuffer
```

### VZDump Backup Configuration

| Variable Name | Description | Default Value |
|---------------|-------------|---------------|
| `tmpdir` | Temporary directory for backups | `/dev/shm` |
| `bwlimit` | Bandwidth limit (KB/s) | `35000` |
| `ionice` | I/O priority class (0-7) | `5` |

### System Packages

| Variable Name | Description | Default Value |
|---------------|-------------|---------------|
| `pve_system_packages` | List of system packages to install | See defaults |

**Default Packages:**
- Download utilities: `aria2`, `wget`, `curl`, `unzip`, `zip`
- Network utilities: `ipset`, `iperf`, `iftop`, `iotop`
- System utilities: `nano`, `build-essential`, `htop`
- Security: `haveged`
- Storage: `zfsutils-linux`, `cifs-utils`

### ISO & Template Management

| Variable Name | Description | Default Value |
|---------------|-------------|---------------|
| `proxmox_iso_dir` | Directory for ISO storage | `/var/lib/vz/template/iso` |
| `proxmox_iso_urls` | List of ISO URLs to download | `[]` |
| `proxmox_iso_remove` | List of ISO filenames to remove | `[]` |
| `proxmox_lxc_storage` | Storage ID for LXC templates | `local` |
| `proxmox_lxc_templates` | List of LXC templates to download | `[]` |
| `proxmox_lxc_remove` | List of LXC template filenames to remove | `[]` |

### VM/LXC Configuration Deployment

| Variable Name | Description | Default Value |
|---------------|-------------|---------------|
| `pve_deploy_vm_configs` | Deploy VM configs from `files/vm_configs/` | `false` |
### Other Configuration

| Variable Name | Description | Default Value |
|---------------|-------------|---------------|
| `ansible_managed` | Ansible managed header text | `ansible managed` |

## Dependencies

No external dependencies.

## Example Playbooks

### Basic Configuration

```yaml
---
- name: Configure Proxmox VE Server
  hosts: proxmox
  become: true
  roles:
    - role: brcak_zmaj.almir_ansible.proxmox
  vars:
    pve_repo_type: no-subscription
    pve_set_cpu: yes
    pve_cpu_governor: performance
```

### Full Configuration with ZFS and GPU Passthrough

```yaml
---
- name: Configure Proxmox VE Server
  hosts: proxmox
  become: true
  roles:
    - role: brcak_zmaj.almir_ansible.proxmox
  vars:
    # Repository
    pve_repo_type: no-subscription
    pve_install_ucode: true
    
    # CPU Tuning
    pve_set_cpu: yes
    pve_cpu_governor: performance
    
    # ZFS Configuration
    pve_zfs_scrub_enable: true
    pve_zfs_scrub_hour: "2"  # 2 AM
    
    # GPU Passthrough
    pve_gpu_passthrough_enable: true
    
    # Backup Configuration
    tmpdir: /mnt/backups/tmp
    bwlimit: 50000
    
    # ISO Management
    proxmox_iso_urls:
      - 'https://releases.ubuntu.com/24.04.3/ubuntu-24.04.3-live-server-amd64.iso'
    
    # LXC Templates
    proxmox_lxc_templates:
      - 'system/debian-12-standard_12.12-1_amd64.tar.zst'
      - 'system/ubuntu-22.04-standard_22.04-1_amd64.tar.zst'
```

### VM/LXC Configuration Migration

```yaml
---
- name: Migrate Proxmox Configurations
  hosts: proxmox_new
  become: true
  roles:
    - role: brcak_zmaj.almir_ansible.proxmox
  vars:
    pve_deploy_vm_configs: true  # Deploy configs from files/vm_configs/ and files/lxc_configs/
```

**Note:** Before deploying VM/LXC configs:
1. Use `files/backup_proxmox_configs.sh` to backup configs from source server
2. Ensure storage pools and disks are imported on target server
3. Set `pve_deploy_vm_configs: true` to deploy configurations

## Tags

This role supports the following tags for selective execution:

- `ISOs` - ISO and LXC template management only
- `vm_configs` - VM/LXC configuration deployment only

**Example:**
```yaml
ansible-playbook playbook.yml --tags ISOs
```

## Tasks Included

### Repository & Packages
- Configure Debian base repositories
- Configure Proxmox VE repositories
- Install microcode updates (Intel/AMD)
- Install system packages

### System Tuning
- Configure CPU governor (systemd service)
- Configure KSM (Kernel Same-page Merging) with RAM-based tuning
- Enable and start KSM daemon

### ZFS Optimization
- Calculate and configure ZFS ARC cache limits
- Configure ZFS scrub schedule (monthly)
- Update ZFS auto-snapshot retention policies
- Create ZFS ARC modprobe configuration

### GPU Passthrough
- Check IOMMU support
- Configure GRUB with IOMMU parameters
- Load VFIO kernel modules
- Configure VFIO-PCI modprobe settings

### Backup Configuration
- Configure VZDump settings (`/etc/vzdump.conf`)

### Subscription Management
- Remove subscription nag from web UI
- Configure APT to prevent subscription prompts

### Python Package Manager
- Install `uv` Python package manager
- Configure shell completion
- Set up weekly auto-update cron job

### ISO & Template Management
- Download ISO images
- Download LXC templates
- Remove old ISOs and templates

### VM/LXC Configuration Deployment
- Deploy VM configurations from `files/vm_configs/`
- Deploy LXC configurations from `files/lxc_configs/`

## Advanced Configuration

### KSM Tuning by RAM Size

KSM parameters are automatically adjusted based on system RAM:

| RAM Size | KSM_THRES_COEF | KSM_SLEEP_MSEC |
|----------|----------------|----------------|
| ≤16GB    | 50             | 80             |
| 16-32GB  | 40             | 60             |
| 32-64GB  | 30             | 40             |
| 64-128GB | 20             | 20             |
| >128GB   | 10             | 10             |

### ZFS ARC Calculation

ZFS ARC limits are calculated automatically:

| RAM Size | ARC Min | ARC Max |
|----------|---------|---------|
| ≤16GB    | 512MB   | 512MB   |
| 16-32GB  | 1GB     | 1GB     |
| >32GB    | RAM/16  | RAM/8   |

### GPU Passthrough Requirements

1. **Hardware Support:**
   - CPU with IOMMU support (Intel VT-d or AMD-Vi)
   - Motherboard with IOMMU enabled in BIOS
   - GPU compatible with passthrough

2. **Verification:**
   - The role checks for IOMMU support using `dmesg`
   - Displays DMAR/IOMMU information if available

3. **After Configuration:**
   - **Reboot required** for GRUB changes to take effect
   - Verify IOMMU is active: `dmesg | grep -e DMAR -e IOMMU`
   - Check GPU in IOMMU groups: `find /sys/kernel/iommu_groups/ -type l`

## Backup Script

The role includes a backup script for migrating VM/LXC configurations:

**Location:** `files/backup_proxmox_configs.sh`

**Usage:**
```bash
# Backup from source server
./files/backup_proxmox_configs.sh root@source-proxmox-server

# Configs will be saved to:
# - files/vm_configs/*.conf
# - files/lxc_configs/*.conf
```

**Note:** The script requires SSH key authentication. Set `SSH_KEY` environment variable if using a non-default key.

## Handlers

This role includes the following handlers:

- `restart cpu-governor service` - Restart CPU governor service
- `restart ksmtuned service` - Restart KSM daemon
- `update initramfs` - Update initramfs (for ZFS/VFIO changes)
- `proxmox-widget-toolkit` - Reinstall proxmox-widget-toolkit (subscription nag removal)
- `UpdateCache` - Update APT cache

## Idempotency

All tasks in this role are designed to be idempotent. You can safely run the role multiple times without side effects.

## Troubleshooting

### ZFS ARC Warning on Boot

If you see warnings about ZFS ARC configuration on boot:
- This is normal - the configuration is applied correctly
- The warning appears because ZFS loads before the modprobe config
- After the role runs and updates initramfs, the warning should disappear on next boot

### GPU Passthrough Not Working

1. Verify IOMMU is enabled in BIOS/UEFI
2. Check that IOMMU is active: `dmesg | grep -e DMAR -e IOMMU`
3. Ensure you've rebooted after running the role
4. Check IOMMU groups: `find /sys/kernel/iommu_groups/ -type l`

### KSM Not Active

- Check KSM status: `cat /sys/kernel/mm/ksm/run` (should be `1`)
- Check KSM daemon: `systemctl status ksmtuned`
- Review KSM configuration: `cat /etc/ksmtuned.conf`

### Microcode Not Applied

- Microcode updates require a reboot to take effect
- Set `pve_reboot_for_ucode: true` to enable automatic reboot (use with caution)
- Or manually reboot after running the role

## Notes

- **Reboot Required:** GPU passthrough configuration requires a reboot to take effect
- **ZFS Optional:** ZFS features are automatically skipped if ZFS is not installed
- **Root Access:** Some tasks require root access (use `become: true`)

## License

GPL-3.0-or-later

## Author Information

- [Almir Zohorovic](https://github.com/brcak-zmaj)


## Stats

![Alt](https://repobeats.axiom.co/api/embed/7a7fe37d43ef2cab7bdbc23ba8c5cfe3cfbdf832.svg "Repobeats analytics image")
