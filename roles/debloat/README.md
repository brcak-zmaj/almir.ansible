<img src="https://raw.githubusercontent.com/geerlingguy/mac-dev-playbook/master/files/Mac-Dev-Playbook-Logo.png" width="250" height="156" alt="Playbook Logo" />

# Ansible Role - System Debloat

A comprehensive Ansible role for removing unnecessary packages, bloatware, and system components from Linux distributions (Fedora, RHEL, CentOS, Debian, Ubuntu).

## Features

This role provides comprehensive system debloating capabilities:

### 📦 Package Removal
- **Common Packages**: Remove bloatware, games, and unnecessary applications across all distributions
- **Distribution-Specific**: Remove packages specific to RedHat-based or Debian-based systems
- **Language Packs**: Remove language packs and localization files (supports wildcards)
- **Font Packages**: Remove language-specific fonts you don't need
- **LibreOffice**: Remove help and localization packs for languages you don't use
- **Custom Packages**: User-defined additional packages to remove
- **Flatpak Packages**: Remove Flatpak applications (system and user-level)

### 🛡️ Safety Features
- **Keep List**: Whitelist packages to prevent removal even if they're in debloat lists
- **Wildcard Support**: Match package patterns (e.g., `language-pack-gnome-*`)
- **Smart Filtering**: Only attempts to remove packages that are actually installed
- **Idempotent**: Safe to run multiple times - Ansible handles package state natively

### 📊 Reporting
- **Debug Mode**: Optional detailed output of packages found and targeted for removal
- **Clean Execution**: Relies on Ansible's native idempotency for status reporting

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
| `debloat_debug` | Enable debug output showing packages found for removal | `false` |
| `debloat_flatpak_user` | Username for user-level Flatpak removal (leave empty to skip) | `"almir"` |
| `debloat_extra_packages` | Additional system packages to remove (merged with defaults) | `[]` |
| `debloat_extra_flatpaks` | Additional Flatpak app IDs to remove (merged with defaults) | `[]` |
| `keep_packages` | Packages to exclude from removal (whitelist) | `[]` |

### Default Package Lists (Customizable)

| Variable Name | Description | Default |
|---------------|-------------|---------|
| `common_debloat` | Common bloatware packages (all distributions) | See `defaults/main.yml` |
| `redhat_debloat` | RedHat-specific packages (Fedora, RHEL, CentOS) | See `defaults/main.yml` |
| `debian_debloat` | Debian-specific packages (Debian, Ubuntu) | See `defaults/main.yml` |
| `language_packs` | Language packs to remove (supports wildcards like `*`) | See `defaults/main.yml` |
| `font_packages` | Language-specific font packages | See `defaults/main.yml` |
| `uninstall_flatpak_packages` | Flatpak application IDs to uninstall | `[]` |

### Package Categories Included by Default

The role targets these categories:
- **Games**: GNOME games, card games, puzzles (aisleriot, gnome-mines, gnome-sudoku, etc.)
- **Productivity**: Unwanted apps (Thunderbird, Evolution, Rhythmbox, Brasero, etc.)
- **System Tools**: Cockpit, toolbox, simple-scan, open-vm-tools
- **LibreOffice**: Help and localization packs for non-English languages
- **Fonts**: Language-specific fonts (Arabic, Hebrew, Indian languages, CJK, etc.)
- **Language Packs**: GNOME language packs for non-English languages

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

### With Debug Output

```yaml
---
- name: Remove bloat with debug information
  hosts: all
  become: true
  roles:
    - role: brcak_zmaj.almir_ansible.debloat
      vars:
        debloat_debug: true
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
        debloat_extra_packages:
          - unwanted-package-1
          - unwanted-package-2
        keep_packages:
          - kf6-kdoctools              # Prevents KDE cascade removal
          - evolution-data-server      # Keep GNOME mail/calendar
          - totem-pl-parser           # Keep media library dependencies
```

### Remove Custom Flatpaks

```yaml
---
- name: Remove bloat and specific Flatpaks
  hosts: all
  become: true
  roles:
    - role: brcak_zmaj.almir_ansible.debloat
      vars:
        uninstall_flatpak_packages:
          - org.example.UnwantedApp
          - com.somevendor.Application
        debloat_flatpak_user: "myusername"
```

## How It Works

1. **Build Removal Lists**: Combines common, OS-specific, language, and font packages into a master list
2. **Filter Keep List**: Removes any packages in `keep_packages` from the removal list
3. **Gather System Facts**: Queries installed packages using `package_facts`
4. **Match Wildcards**: Expands wildcard patterns (like `language-pack-*`) against installed packages
5. **Filter Installed**: Creates final list containing only packages actually installed on the system
6. **Remove Packages**: Uses native DNF (Fedora/RHEL) or APT (Debian/Ubuntu) to remove packages
7. **Remove Flatpaks**: Removes Flatpak applications at system and user level (if configured)

## Notes

- **Idempotency**: The role is idempotent - safe to run multiple times
- **Dependency Handling**: DNF/APT will prevent removal of packages needed by installed software
- **No Forced Removal**: Does not use `--nodeps` or similar dangerous flags

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
