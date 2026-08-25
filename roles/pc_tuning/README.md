
# pc_tuning

Ansible role for optimizing Linux workstations and desktops with performance-focused kernel parameters.

## Overview

This role configures sysctl settings and user resource limits to optimize desktop/workstation performance. It includes network stack tuning, memory management, and enables modern TCP features like BBR congestion control.

## Requirements

- **Ansible**: `>= 2.9`
- **Collections**: `ansible.posix`, `community.general`

## Supported Platforms

| OS Family | Tested Versions |
|-----------|-----------------|
| RedHat    | RHEL 8+, Rocky 8+, Fedora 35+ |
| Debian    | Ubuntu 20.04+, Debian 11+ |

## Role Variables

### Memory Settings (Auto-calculated)

| Variable | Default | Description |
|----------|---------|-------------|
| `user_shmmax` | 75% of RAM | Maximum shared memory segment size |
| `user_shmall` | Calculated | Total shared memory pages |
| `user_nr_open` | `1048576` | Max file descriptors system-wide |
| `user_nofile` | `1048576` | Max file descriptors per process |

### Sysctl Settings

The `workstation_sysctl_settings` list includes:

| Setting | Default Value | Description |
|---------|---------------|-------------|
| `net.core.rmem_max` | `67108864` | Max receive socket buffer |
| `net.core.wmem_max` | `67108864` | Max send socket buffer |
| `net.core.netdev_max_backlog` | `250000` | Network device backlog queue |
| `net.ipv4.tcp_rmem` | `4096 87380 67108864` | TCP receive buffer sizes |
| `net.ipv4.tcp_wmem` | `4096 65536 67108864` | TCP send buffer sizes |
| `net.ipv4.tcp_congestion_control` | `bbr` | TCP congestion control algorithm |
| `net.ipv4.tcp_fastopen` | `3` | TCP Fast Open mode |
| `net.ipv4.tcp_mtu_probing` | `1` | Enable MTU probing |
| `vm.swappiness` | `10` | Swap usage preference |
| `vm.dirty_ratio` | `10` | Max dirty pages percentage |
| `vm.dirty_background_ratio` | `5` | Background writeback threshold |

## What This Role Configures

- **Sysctl parameters**: Network, memory, and file descriptor tuning
- **User limits**: nofile, nproc, and memlock limits
- **TCP BBR**: Enables BBR congestion control for better network performance
- **Persistent configuration**: Settings saved to `/etc/sysctl.d/99-workstation-tuning.conf`

## Installation

```bash
ansible-galaxy collection install brcak_zmaj.almir_ansible
```

## Example Playbook

### Basic Usage

```yaml
---
- name: Tune workstation
  hosts: workstations
  become: true

  roles:
    - role: brcak_zmaj.almir_ansible.pc_tuning
```

### Custom Configuration

```yaml
---
- name: Tune workstation with custom settings
  hosts: workstations
  become: true

  roles:
    - role: brcak_zmaj.almir_ansible.pc_tuning
      vars:
        user_nofile: 524288
```

## Tags

- `pc_tuning` - All tasks
- `sysctl` - Sysctl configuration tasks
- `limits` - User limit tasks

## License

GPL-3.0-or-later

## Author Information

This role is maintained as part of the `brcak_zmaj.almir_ansible` collection.

- Almir Zohorovic

## Support

For issues, questions, or contributions, please use the [GitHub Issues](https://github.com/brcak-zmaj/almir.ansible/issues) page.
