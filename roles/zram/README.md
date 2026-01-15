# Ansible Role: zram

Manage Linux memory compression using **zram** via systemd `zram-generator`.

## Overview

zram creates compressed RAM-based block devices that can be used as swap space. This provides:
- Faster swap performance than disk-based swap
- Effective memory compression (typically 2:1 to 3:1 ratio)
- Reduced disk I/O and SSD wear

This role uses the modern `zram-generator` systemd integration, which is the recommended approach for managing zram on systemd-based distributions.

## Requirements

- Kernel with `CONFIG_ZRAM` enabled (standard on modern distributions)
- systemd-based distribution

## Supported Platforms

| Distribution | Versions |
|--------------|----------|
| Fedora | 38, 39, 40, 41, 42, 43 |
| RHEL/Rocky/Alma | 8, 9 |
| Debian | Bullseye, Bookworm |
| Ubuntu | 20.04 (Focal), 22.04 (Jammy), 24.04 (Noble) |

## Role Behavior

The role:
1. Detects kernel zram support
2. Gathers current zram state (size, compression algorithm)
3. Displays current vs desired configuration
4. Installs `zram-generator` package if needed
5. Deploys configuration **only when it differs** from desired state
6. Restarts zram only when configuration changes

The role is fully idempotent - running it multiple times with the same settings produces no changes.

## Role Variables

### Basic Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `zram_enabled` | `true` | Enable/disable the role |
| `zram_device_name` | `zram0` | Device name |
| `zram_size` | `min(ram, 8192)` | Size formula (see below) |
| `zram_compression_algorithm` | `""` | Compression algorithm (empty = kernel default) |
| `zram_swap_priority` | `100` | Swap priority (higher = preferred) |

### Size Formula

The `zram_size` variable accepts formulas using the `ram` variable (total RAM in MB):

```yaml
# Conservative: half of RAM, max 4GB
zram_size: "min(ram / 2, 4096)"

# Default: equal to RAM, max 8GB
zram_size: "min(ram, 8192)"

# Aggressive: 2x RAM (for low-memory systems)
zram_size: "ram * 2"

# Fixed size
zram_size: "4096"
```

### Compression Algorithms

| Algorithm | Speed | Ratio | Notes |
|-----------|-------|-------|-------|
| `lzo-rle` | Fast | Good | Kernel default, best balance |
| `lz4` | Fastest | Lower | Lowest CPU overhead |
| `zstd` | Slower | Best | Best compression ratio |
| `lzo` | Fast | Good | Legacy, use lzo-rle instead |

### Advanced Options

| Variable | Default | Description |
|----------|---------|-------------|
| `zram_host_memory_limit` | `none` | Disable zram on systems with more RAM than this (MB) |

## Example Playbook

```yaml
- hosts: all
  become: true
  roles:
    - role: brcak_zmaj.almir_ansible.zram
```

### Change Existing Configuration

The role automatically detects when configuration needs to change:

```yaml
# If zram is currently 8GB but you want 4GB, just run:
- hosts: all
  become: true
  roles:
    - role: brcak_zmaj.almir_ansible.zram
      vars:
        zram_size: "min(ram / 2, 4096)"  # Change from default 8GB to 4GB max
```

### Disable on High-Memory Systems

```yaml
- hosts: all
  become: true
  roles:
    - role: brcak_zmaj.almir_ansible.zram
      vars:
        zram_host_memory_limit: "65536"  # Skip if >64GB RAM
```

## Tags

- `zram` - All tasks in this role

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