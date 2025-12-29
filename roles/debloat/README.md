<img src="https://raw.githubusercontent.com/geerlingguy/mac-dev-playbook/master/files/Mac-Dev-Playbook-Logo.png" width="250" height="156" alt="Playbook Logo" />

# Ansible Role - System Debloat

A comprehensive Ansible role for removing unnecessary packages, bloatware, and system components from Linux distributions (Fedora, RHEL, CentOS, Debian, Ubuntu).

## Features

This role provides comprehensive system debloating capabilities:

### 📦 Package Removal
- **Common Packages**: Remove bloatware, games, and unnecessary applications across all distributions
- **Distribution-Specific**: Remove packages specific to RedHat-based or Debian-based systems
- **Language Packs**: Remove language packs and localization files
- **Font Packages**: Remove language-specific font packages
- **Custom Packages**: User-defined additional packages to remove
- **Flatpak Packages**: Remove Flatpak applications

### 🛡️ Safety Features
- **Keep List**: Whitelist packages to prevent removal even if they're in debloat lists
- **Pre-installation Checks**: Only attempts to remove packages that are actually installed
- **Dependency Handling**: Gracefully handles dependency conflicts with `skip_broken`
- **Error Suppression**: Prevents false failures from non-installed packages

### 📊 Reporting
- **Summary Output**: Displays what was removed after debloat operations
- **Clean Logging**: Suppresses terminal escape sequences and unnecessary warnings

## Requirements

### Ansible Version Compatibility

This role is tested and supported with:
- **Ansible**: `>= 2.9`
- **Python**: `>= 3.6` (on target system)

### Target System Requirements

- **OS**: Linux (Fedora, RHEL, CentOS, Debian, Ubuntu)
- **Access**: SSH access with sudo/root privileges
- **Python**: Python 3 installed on target system

### Dependencies

- **community.general**: Required for Flatpak package management

## Installation

This role is part of the `brcak_zmaj.almir_ansible` collection. Install the collection:

```bash
ansible-galaxy collection install brcak_zmaj.almir_ansible
```

## Role Variables

### Core Variables

| Variable Name | Description | Default Value |
|---------------|-------------|---------------|
| `debloat_show_summary` | Display summary after debloat operations | `true` |
| `common_debloat` | List of common packages to remove (all distributions) | See defaults |
| `redhat_debloat` | List of RedHat-specific packages to remove | See defaults |
| `debian_debloat` | List of Debian-specific packages to remove | See defaults |
| `language_packs` | List of language packs to remove | See defaults |
| `font_packages` | List of font packages to remove | See defaults |
| `custom_debloat_packages` | User-defined additional packages to remove | `[]` |
| `keep_packages` | Packages to keep (exclude from removal) | `[]` |
| `uninstall_flatpak_packages` | Flatpak packages to uninstall | `[]` |

### Package Lists

The role includes comprehensive default lists for:
- Common bloatware (games, unnecessary apps, LibreOffice help/locale packs)
- RedHat-specific packages (cockpit, podman, etc.)
- Debian-specific packages
- Language packs (with wildcard support)
- Font packages (language-specific fonts)

## Dependencies

- **community.general**: Required for Flatpak package management

## Example Playbooks

### Basic Usage

```yaml
---
- name: Remove system bloat
  hosts: all
  become: true
  roles:
    - role: brcak_zmaj.almir_ansible.debloat
```

### Custom Packages and Keep List

```yaml
---
- name: Remove bloat with custom configuration
  hosts: all
  become: true
  roles:
    - role: brcak_zmaj.almir_ansible.debloat
  vars:
    custom_debloat_packages:
      - unwanted-package-1
      - unwanted-package-2
    keep_packages:
      - evolution  # Keep even though it's in common_debloat
      - podman     # Keep even though it's in redhat_debloat
```

### Disable Summary

```yaml
---
- name: Remove bloat without summary
  hosts: all
  become: true
  roles:
    - role: brcak_zmaj.almir_ansible.debloat
  vars:
    debloat_show_summary: false
```

## How It Works

1. **Environment Setup**: Sets environment variables to suppress terminal escape sequences
2. **Filtering**: Filters out packages in the `keep_packages` list from all debloat lists
3. **Pre-checks**: Verifies which packages are actually installed before attempting removal
4. **Removal**: Removes only installed packages, skipping those with dependency conflicts
5. **Summary**: Displays a summary of what was removed (if enabled)

## Safety Features

- **Pre-installation Checks**: Only attempts to remove packages that are installed
- **Keep List**: Packages in `keep_packages` are never removed, even if in debloat lists
- **Dependency Handling**: Uses `skip_broken` to handle dependency conflicts gracefully
- **Error Suppression**: Prevents false failures from non-installed packages

## Notes

- **Idempotency**: The role is idempotent - running it multiple times is safe
- **Dependency Conflicts**: Some packages may have dependency conflicts (e.g., cockpit, open-vm-tools). The role handles these gracefully with `skip_broken`
- **Terminal Warnings**: Some terminal escape sequence warnings may appear but are harmless
- **Wildcard Support**: Language packs support wildcards (e.g., `language-pack-gnome-*`)
- **Distribution Detection**: Automatically detects OS family and applies appropriate debloat lists

## License

GPL-3.0-or-later

## Author Information

- [Almir Zohorovic](https://github.com/brcak-zmaj)

## Stats

![Alt](https://repobeats.axiom.co/api/embed/7a7fe37d43ef2cab7bdbc23ba8c5cfe3cfbdf832.svg "Repobeats analytics image")

