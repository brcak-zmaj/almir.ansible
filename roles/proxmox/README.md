# Ansible Role - Proxmox VE

A comprehensive Ansible role for configuring and optimizing Proxmox VE hypervisor hosts with ZFS tuning, GPU passthrough, backup configuration, and ISO/LXC template management.

## Overview

This role automates the post-installation configuration of Proxmox VE hosts, providing enterprise-ready optimizations including ZFS ARC tuning, CPU governor configuration, GPU passthrough setup, subscription nag removal, and automated ISO/LXC template management.

## Features

### System Configuration
- **Subscription Nag Removal**: Remove Proxmox subscription notification popup
- **Repository Configuration**: Configure enterprise or no-subscription repositories
- **Microcode Installation**: Automatic CPU microcode updates (Intel/AMD)
- **CPU Governor**: Configurable CPU frequency scaling governor
- **System Packages**: Install essential utilities (htop, iotop, iftop, aria2, etc.)

### ZFS Optimization
- **Auto-calculated ARC**: Dynamically calculates ZFS ARC min/max based on system RAM:
  - ≤16GB: min=512MB, max=512MB
  - 16-32GB: min=1GB, max=1GB
  - 32-64GB: min=RAM/16, max=RAM/8
  - >64GB: min=RAM/8, max=RAM/2 (aggressive caching)
- **Scrub Scheduling**: Configurable ZFS scrub schedule (default: 2nd Sunday monthly)

### GPU Passthrough
- **IOMMU Configuration**: Automatic Intel/AMD IOMMU GRUB parameters
- **VFIO Setup**: Configure VFIO kernel modules for PCI passthrough
- **GPU Blacklisting**: Prevent host from loading GPU drivers
- **VM Binding**: Bind specific GPUs to designated VMs

### Backup Configuration
- **VZDump Settings**: Configure backup temp directory and bandwidth limits
- **I/O Priority**: Configurable ionice values for backups

### Template Management
- **ISO Downloads**: Download ISOs from URL list with automatic hash verification
- **LXC Templates**: Download LXC templates from Proxmox appliance repository
- **Cleanup**: Remove obsolete ISOs and templates

### Python Environment
- **UV Installation**: Install modern Python package manager (uv/astral-uv)

## Requirements

### Ansible Version Compatibility

This role is tested and supported with:
- **Ansible**: `>= 2.9`
- **Python**: `>= 3.6` (on control node)

### Target System Requirements

- **OS**: Proxmox VE 7.x or 8.x
- **Access**: SSH access with root privileges
- **Storage**: ZFS storage pool (for ZFS tuning features)

### Dependencies

- `ansible.builtin`
- `ansible.posix`
- `community.general`

## Installation

This role is part of the `brcak_zmaj.almir_ansible` collection. Install the collection:

```bash
ansible-galaxy collection install brcak_zmaj.almir_ansible
```

## Role Variables

### VZDump Backup Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `tmpdir` | Temporary directory for backups | `/dev/shm` |
| `bwlimit` | Bandwidth limit (KB/s) | `35000` |
| `ionice` | I/O priority (0-7, lower = higher priority) | `5` |

### Repository Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `pve_repo_type` | Repository type (`enterprise`, `no-subscription`) | `no-subscription` |
| `pve_install_ucode` | Install CPU microcode updates | `true` |
| `pve_reboot_for_ucode` | Reboot after microcode update | `false` |

### CPU Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `pve_set_cpu` | Enable CPU governor configuration | `no` |
| `pve_cpu_governor` | CPU frequency governor | `performance` |

### ZFS Scrub Schedule

| Variable | Description | Default |
|----------|-------------|---------|
| `pve_zfs_scrub_enable` | Enable ZFS scrub scheduling | `true` |
| `pve_zfs_scrub_minute` | Cron minute (0-59) | `24` |
| `pve_zfs_scrub_hour` | Cron hour (0-23) | `0` |
| `pve_zfs_scrub_day_start` | Day range start | `8` |
| `pve_zfs_scrub_day_end` | Day range end | `14` |

### GPU Passthrough

| Variable | Description | Default |
|----------|-------------|---------|
| `pve_gpu_passthrough_enable` | Enable GPU passthrough configuration | `true` |
| `pve_gpu_vendor_id` | GPU PCI vendor:device ID | `10de:13ba` |
| `pve_gpu_audio_id` | GPU audio device ID | `10de:0fbc` |
| `pve_gpu_passthrough_vm_id` | Target VM ID for GPU | `105` |
| `pve_iommu_grub_params` | GRUB IOMMU parameters | See defaults |

### ISO Management

| Variable | Description | Default |
|----------|-------------|---------|
| `proxmox_iso_dir` | ISO storage directory | `/var/lib/vz/template/iso` |
| `proxmox_iso_urls` | List of ISO URLs to download | See defaults |
| `proxmox_iso_remove` | List of ISOs to remove | `[]` |

### LXC Template Management

| Variable | Description | Default |
|----------|-------------|---------|
| `proxmox_lxc_storage` | LXC template storage ID | `local` |
| `proxmox_lxc_templates` | Templates to download | See defaults |
| `proxmox_lxc_remove` | Templates to remove | `[]` |

### VM Configuration Deployment

| Variable | Description | Default |
|----------|-------------|---------|
| `pve_deploy_vm_configs` | Deploy VM/LXC configs from files/ | `false` |

### System Packages

| Variable | Description | Default |
|----------|-------------|---------|
| `pve_system_packages` | List of packages to install | See defaults |

## Tags

Run specific tasks using tags:

```bash
# Only manage ISOs and templates
ansible-playbook playbook.yml --tags ISOs

# Only deploy VM configurations
ansible-playbook playbook.yml --tags vm_configs
```

## Example Playbooks

### Basic Proxmox Host Configuration

```yaml
---
- name: Configure Proxmox VE host
  hosts: proxmox_servers
  become: true

  roles:
    - role: brcak_zmaj.almir_ansible.proxmox
```

### Full Configuration with GPU Passthrough

```yaml
---
- name: Configure Proxmox with GPU passthrough
  hosts: proxmox_gpu_host
  become: true

  vars:
    pve_gpu_passthrough_enable: true
    pve_gpu_vendor_id: "10de:2204"      # RTX 3090
    pve_gpu_audio_id: "10de:1aef"       # RTX 3090 Audio
    pve_gpu_passthrough_vm_id: 100
    pve_set_cpu: "yes"
    pve_cpu_governor: performance

  roles:
    - role: brcak_zmaj.almir_ansible.proxmox
```

### Template and ISO Management

```yaml
---
- name: Manage Proxmox templates
  hosts: proxmox_servers
  become: true

  vars:
    proxmox_iso_urls:
      - 'https://releases.ubuntu.com/24.04/ubuntu-24.04-live-server-amd64.iso'
      - 'https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.4.0-amd64-netinst.iso'
    proxmox_lxc_templates:
      - 'system/debian-12-standard_12.12-1_amd64.tar.zst'
      - 'system/ubuntu-24.04-standard_24.04-2_amd64.tar.zst'
      - 'system/alpine-3.19-default_20240207_amd64.tar.xz'

  roles:
    - role: brcak_zmaj.almir_ansible.proxmox
```

## Task Files

| File | Purpose |
|------|---------|
| `preconfig.yml` | Pre-configuration (hosts, SSH, etc.) |
| `ucode.yml` | Repository and microcode configuration |
| `packages.yml` | System package installation |
| `system_config.yml` | CPU governor and KSM configuration |
| `zfs-tune.yml` | ZFS ARC and scrub configuration |
| `pcie_passthrough.yml` | GPU/PCIe passthrough setup |
| `vzdump.yml` | VZDump backup configuration |
| `subscription-nag.yml` | Remove subscription popup |
| `uv_install.yml` | UV Python manager installation |
| `proxmox_ISO_manager.yml` | ISO and LXC template management |
| `vm_config_deploy.yml` | VM/LXC configuration deployment |

## Supported Platforms

| Platform | Tested Versions |
|----------|-----------------|
| Proxmox VE | 7.4, 8.0, 8.1, 8.2, 8.3 |

## License

GPL-3.0-or-later

## Author Information

> Note: I am providing code in the repository to you under an open source license. Because this is my personal repository, the license you receive to my code is from me and not my employer.

This role is maintained as part of the `brcak_zmaj.almir_ansible` collection.
- Almir Zohorovic

## Support

For issues, questions, or contributions, please use the [GitHub Issues](https://github.com/brcak-zmaj/almir.ansible/issues) page.


## Stats

![Alt](https://repobeats.axiom.co/api/embed/7a7fe37d43ef2cab7bdbc23ba8c5cfe3cfbdf832.svg "Repobeats analytics image")