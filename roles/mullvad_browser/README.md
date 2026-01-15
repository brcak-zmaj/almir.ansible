# mullvad_browser

Install and manage Mullvad Browser on RedHat and Debian family systems.

## Description

This role installs Mullvad Browser from the official Mullvad repository. It supports both stable and alpha versions, handles repository configuration, and provides cleanup/uninstallation capabilities.

## Supported Platforms

| OS Family | Distributions |
|-----------|---------------|
| RedHat | Fedora 41+ |
| Debian | Debian 11+, Ubuntu 20.04+ |

> **Note:** For RedHat family, this role is designed for **Fedora 41 and newer** due to changes in the `dnf config-manager` syntax.

## Requirements

- Ansible 2.14 or higher
- Root/sudo access on target systems
- Internet connectivity to download packages from Mullvad repositories

## Role Variables

### Required Variables

None. All variables have sensible defaults.

### Optional Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `mullvad_browser_state` | `present` | State of the package. Options: `present`, `absent` |
| `mullvad_browser_install_alpha` | `false` | Install alpha version instead of stable |
| `mullvad_browser_add_repository` | `true` | Whether to configure the Mullvad repository |
| `mullvad_browser_package_stable` | `mullvad-browser` | Name of the stable package |
| `mullvad_browser_package_alpha` | `mullvad-browser-alpha` | Name of the alpha package |

#### RedHat-specific Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `mullvad_browser_rhel_repo_url` | `https://repository.mullvad.net/rpm/stable/mullvad.repo` | Repository URL |
| `mullvad_browser_rhel_repo_file` | `/etc/yum.repos.d/mullvad.repo` | Repository file path |

#### Debian-specific Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `mullvad_browser_debian_keyring_url` | `https://repository.mullvad.net/deb/mullvad-keyring.asc` | GPG key URL |
| `mullvad_browser_debian_keyring_path` | `/usr/share/keyrings/mullvad-keyring.asc` | GPG key path |
| `mullvad_browser_debian_repo_url` | `https://repository.mullvad.net/deb/stable` | Repository URL |
| `mullvad_browser_debian_repo_file` | `/etc/apt/sources.list.d/mullvad.list` | Repository file path |

## Dependencies

None.

## Example Playbook

### Install stable version (default)

```yaml
---
- name: Install Mullvad Browser
  hosts: workstations
  become: true
  roles:
    - mullvad_browser
```

## Author Information

- Almir Zohorovic
