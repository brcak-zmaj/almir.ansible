# Ansible Role - cifs_utils

A simple Ansible role for installing or uninstalling CIFS/SMB utilities on Linux systems to enable mounting Windows/Samba network shares.

## Overview

This role manages the `cifs-utils` package, which provides utilities for mounting SMB/CIFS network shares on Linux systems. Supports both installation and removal via a boolean toggle.

## Features

- **Cross-Platform**: Supports RedHat-based and Debian-based distributions
- **Idempotent**: Safe to run multiple times
- **Reversible**: Can install or uninstall via boolean switch
- **Simple**: Single-purpose role for managing CIFS utilities

## Requirements

- **Ansible**: `>= 2.9`
- **OS**: Linux (RedHat-based or Debian-based)
- **Access**: SSH access with sudo/root privileges
- **Internet**: Access to package repositories

## Installation

```bash
ansible-galaxy collection install brcak_zmaj.almir_ansible
```

## Role Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `cifs_utils_install` | `true` | Set to `true` to install cifs-utils, `false` to uninstall |

## Supported Platforms

| OS Family | Tested Versions |
|-----------|-----------------|
| Debian    | Ubuntu 20.04+, Debian 11+ |
| RedHat    | RHEL 8+, Rocky 8+, Fedora 35+ |

## Example Playbook

### Install CIFS Utilities (default)

```yaml
---
- name: Install CIFS utilities
  hosts: all
  become: true

  roles:
    - role: brcak_zmaj.almir_ansible.cifs_utils
```

### Uninstall CIFS Utilities

```yaml
---
- name: Remove CIFS utilities
  hosts: all
  become: true

  roles:
    - role: brcak_zmaj.almir_ansible.cifs_utils
      vars:
        cifs_utils_install: false
```

## Tags

- `cifs_utils` - All tasks

## License

GPL-3.0-or-later

## Author Information

This role is maintained as part of the `brcak_zmaj.almir_ansible` collection.

- Almir Zohorovic

## Support

For issues, questions, or contributions, please use the [GitHub Issues](https://github.com/brcak-zmaj/almir.ansible/issues) page.
