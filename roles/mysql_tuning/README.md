
# mysql_tuning

Ansible role for optimizing Linux kernel parameters for MySQL database servers.

## Overview

This role configures sysctl settings, user limits, and systemd service overrides to optimize MySQL performance on both RedHat and Debian-based systems. Memory parameters are automatically calculated based on available system RAM.

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
| `mysql_sysctl_overcommit_memory` | `1` | Memory overcommit policy (1 = always overcommit) |
| `mysql_sysctl_tcp_fin_timeout` | `30` | TCP FIN timeout in seconds |
| `mysql_sysctl_tcp_keepalive_time` | `300` | TCP keepalive time in seconds |
| `mysql_sysctl_tcp_tw_reuse` | `1` | Allow reuse of TIME-WAIT sockets |
| `mysql_sysctl_file_max` | `2097152` | Maximum number of file handles |
| `mysql_sysctl_shmmax` | `[]` | Max shared memory segment (auto-calculated if empty) |
| `mysql_sysctl_shmall` | `4294967296` | Total shared memory pages |

### User Limits

| Variable | Default | Description |
|----------|---------|-------------|
| `mysql_user_limits` | See defaults | Resource limits for mysql user |

### OS-Specific Settings

| Variable | Default | Description |
|----------|---------|-------------|
| `mysql_debian_sysctl_settings` | `[]` | Additional Debian-specific sysctl settings |
| `mysql_rhel_sysctl_settings` | `[]` | Additional RHEL-specific sysctl settings |

## What This Role Configures

- **Sysctl parameters**: Memory, network, and file descriptor optimizations
- **User limits**: nofile and nproc limits for the mysql user
- **Systemd overrides**: Service limits for MySQL daemon
- **Persistent configuration**: Settings saved to `/etc/sysctl.d/99-mysql.conf`

## Installation

```bash
ansible-galaxy collection install brcak_zmaj.almir_ansible
```

## Example Playbook

### Basic Usage

```yaml
---
- name: Tune MySQL servers
  hosts: mysql_servers
  become: true

  roles:
    - role: brcak_zmaj.almir_ansible.mysql_tuning
```

### Custom Configuration

```yaml
---
- name: Tune MySQL servers with custom settings
  hosts: mysql_servers
  become: true

  roles:
    - role: brcak_zmaj.almir_ansible.mysql_tuning
      vars:
        mysql_sysctl_file_max: 4194304
        mysql_sysctl_tcp_keepalive_time: 600
```

## Tags

- `mysql_tuning` - All tasks
- `sysctl` - Sysctl configuration tasks
- `limits` - User limit tasks
- `systemd` - Systemd override tasks

## License

GPL-3.0-or-later

## Author Information

This role is maintained as part of the `brcak_zmaj.almir_ansible` collection.

- Almir Zohorovic

## Support

For issues, questions, or contributions, please use the [GitHub Issues](https://github.com/brcak-zmaj/almir.ansible/issues) page.
