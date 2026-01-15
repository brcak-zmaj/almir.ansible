
# postgresql_tuning

Ansible role for optimizing Linux kernel parameters for PostgreSQL database servers.

## Overview

This role configures sysctl settings and user limits to optimize PostgreSQL performance on both RedHat and Debian-based systems. Memory parameters are automatically calculated based on available system RAM.

## Requirements

- **Ansible**: `>= 2.9`
- **Collections**: `ansible.posix` (for sysctl module)

## Supported Platforms

| OS Family | Tested Versions |
|-----------|-----------------|
| RedHat    | RHEL 8+, Rocky 8+, CentOS Stream 8+, Fedora 35+ |
| Debian    | Ubuntu 20.04+, Debian 11+ |

## Role Variables

### Kernel Settings

| Variable | Default | Description |
|----------|---------|-------------|
| `postgresql_sysctl_overcommit_memory` | `1` | Memory overcommit policy (1 = always overcommit) |
| `postgresql_sysctl_tcp_fin_timeout` | `30` | TCP FIN timeout in seconds |
| `postgresql_sysctl_tcp_keepalive_time` | `300` | TCP keepalive time in seconds |
| `postgresql_sysctl_tcp_tw_reuse` | `1` | Allow reuse of TIME-WAIT sockets |
| `postgresql_sysctl_file_max` | `2097152` | Maximum number of file handles |
| `postgresql_sysctl_shmmax` | `68719476736` | Max shared memory segment (auto-calculated per OS) |
| `postgresql_sysctl_shmall` | `4294967296` | Total shared memory pages |

### User Limits

| Variable | Default | Description |
|----------|---------|-------------|
| `postgresql_user_limits` | See defaults | Resource limits for postgres user |

### OS-Specific Settings

| Variable | Default | Description |
|----------|---------|-------------|
| `postgresql_debian_sysctl_settings` | `[]` | Additional Debian-specific sysctl settings |
| `postgresql_rhel_sysctl_settings` | `[]` | Additional RHEL-specific sysctl settings |

## What This Role Configures

- **Sysctl parameters**: Memory, network, and file descriptor optimizations
- **User limits**: nofile and nproc limits for the postgres user
- **Persistent configuration**: Settings saved to `/etc/sysctl.d/99-postgresql.conf`

## Installation

```bash
ansible-galaxy collection install brcak_zmaj.almir_ansible
```

## Example Playbook

### Basic Usage

```yaml
---
- name: Tune PostgreSQL servers
  hosts: postgresql_servers
  become: true

  roles:
    - role: brcak_zmaj.almir_ansible.postgresql_tuning
```

### Custom Configuration

```yaml
---
- name: Tune PostgreSQL servers with custom settings
  hosts: postgresql_servers
  become: true

  roles:
    - role: brcak_zmaj.almir_ansible.postgresql_tuning
      vars:
        postgresql_sysctl_file_max: 4194304
        postgresql_sysctl_tcp_keepalive_time: 600
```

## Tags

- `postgresql_tuning` - All tasks
- `sysctl` - Sysctl configuration tasks
- `limits` - User limit tasks

## License

GPL-3.0-or-later

## Author Information

This role is maintained as part of the `brcak_zmaj.almir_ansible` collection.

- Almir Zohorovic

## Support

For issues, questions, or contributions, please use the [GitHub Issues](https://github.com/brcak-zmaj/almir.ansible/issues) page.
