## Ansible Role - My PC Setup

A comprehensive Ansible role for setting up and configuring a Linux development workstation. This role automates the installation of development tools, multimedia codecs, desktop environments, virtualization packages, gaming platforms, and system optimizations.

> **⚠️ Disclaimer**: This role is is just an EXAMPLE role for setting up a dev workstation... While it serves as an example of what Ansible can accomplish, **it is not recommended for production systems**. Use as a reference and customize for your own needs.

## Supported Platforms

- **Debian-based**: Debian 11+, Ubuntu 20.04+
- **RHEL-based**: EL 8+, Fedora 38+

## Requirements

- Ansible >= 2.13
- Target system must be Ubuntu, Debian, Fedora, or RHEL-compatible
- SSH access with sudo privileges

## Overview

This role organizes functionality into modular task groups:

- **prep** - Package manager setup and system updates
- **dev** - Development tools (Node.js, Python, npm packages)
- **games** - Gaming platform setup (Steam)
- **internet** - Remote desktop clients (Remmina)
- **multimedia** - Media codecs and GStreamer plugins
- **posix** - POSIX system tasks (SMB/CIFS mounts, fstab configuration)
- **virtualization** - KVM/QEMU and libvirt setup
- **gnome** - GNOME desktop environment customization

## Role Variables & Defaults

## Role Variables & Defaults

### System & User Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `user` | System user to configure | `almir` |
| `group` | User's primary group | `{{ user }}` |
| `home_dir` | User's home directory | `/home/{{ user }}` |
| `user_priv_ssh` | Private SSH key (from env var) | `$ALMIR_SSH_PRIV_KEY` |
| `user_pub_ssh` | Public SSH key (from env var) | `$ALMIR_SSH_PUB_KEY` |
| `wallpaper_src` | Wallpaper file in `files/` directory | `wallpaper.png` |
| `wallpaper_dest` | Destination for wallpaper | `{{ home_dir }}` |
| `home_dir_clutter` | Home directories to remove | `[Music, Public, Templates, Videos]` |

### Remmina (Remote Desktop Client)

| Variable | Description | Default |
|----------|-------------|---------|
| `remmina_debian_pkgs` | Remmina packages for Debian/Ubuntu | RDP, VNC, SPICE, X2Go support |
| `remmina_redhat_pkgs` | Remmina packages for RHEL/Fedora | RDP, VNC, SPICE, X2Go, WWW plugins |

### Virtualization (libvirt/KVM/QEMU)

| Variable | Description | Default |
|----------|-------------|---------|
| `libvirt_package` | Libvirt daemon package | `libvirtd` |
| `virtualization_packages` | QEMU, KVM, virt-manager, and tools | Bridge utilities, virt-install, virt-top, libguestfs-tools |

### Network Shares (SMB/CIFS)

| Variable | Description | Default |
|----------|-------------|---------|
| `smb_mountpoint` | SMB server IP/hostname | `[]` (example: `10.123.123.123`) |
| `mount_point_directories` | Local mount point paths | `[/mnt/example]` |
| `smb_mounts` | Mount sources and destinations | Maps SMB shares to local paths |
| `smb_credentials` | SMB username/password (from env vars) | `$ALMIR_SMB_USR`, `$ALMIR_SMB_PWD` |
| `smb_mount_opts` | CIFS mount options | Permissions, charset, network-dependent |
| `smb_fstype` | Filesystem type | `cifs` |

### Multimedia & Codecs

| Variable | Description | Default |
|----------|-------------|---------|
| `gstreamer_debian_packages` | GStreamer plugins for Debian/Ubuntu | Base, good, bad, ugly, libav, codec support |
| `gstreamer_redhat_packages` | GStreamer plugins for RHEL/Fedora | Base, good, bad (free), ugly, OpenH.264, FFmpeg |

### Node.js & npm

| Variable | Description | Default |
|----------|-------------|---------|
| `nodejs_npm_packages_debian` | Node.js packages for Debian/Ubuntu | `nodejs`, `npm` |
| `nodejs_npm_packages_redhat` | Node.js packages for RHEL/Fedora | `nodejs`, `npm`, `nodejs-npm` |
| `global_npm_packages` | Global npm packages to install | `@anthropic-ai/claude-code`, `eslint`, `typescript` |

### Python & pip

| Variable | Description | Default |
|----------|-------------|---------|
| `python_packages` | Python system packages | `python3`, `python3-pip` |
| `pip_packages` | Global pip packages | Security: bandit, flake8; API clients: requests, docker, PyGithub; DevOps: ansible-lint; and 15+ others |

### Scheduled Tasks (Cron Jobs)

| Variable | Description | Example |
|----------|-------------|---------|
| `cron_jobs` | List of cron job definitions | Update flatpaks (6am daily), Sync backups (3am daily) |

### Feature Toggles

Enable or disable entire feature sets using boolean flags:

| Feature | Variable | Default |
|---------|----------|---------|
| AWS SDK (boto) | `boto` | `false` |
| Node.js + npm | `node` | `true` |
| Python3 + pip | `python` | `true` |
| Steam gaming | `steam` | `true` |
| GStreamer codecs | `codecs` | `true` |
| Remmina remote desktop | `reminna` | `true` |
| SMB/CIFS mounts | `fstab` | `true` |
| Konsole terminal | `konsole` | `true` |
| Flatpak apps | `flatpak` | `true` |
| CLI utilities | `utilities` | `true` |
| LibreOffice | `libreoffice` | `true` |
| GPaste clipboard manager | `gpaste` | `true` |
| libvirt virtualization | `libvirt` | `false` |
| GNOME desktop tweaks | `gnome` | `true` |
| Autostart applications | `autostart_tweaks` | `true` |
| Custom wallpaper | `wallpaper` | `false` |

## Task Structure

The role is organized into the following task groups:

- `prep/_main.yml` - Package manager setup and system updates (tagged: `package_mgmt`)
- `dev/_main.yml` - Development tools, Node.js, Python, npm
- `games/_main.yml` - Steam and gaming-related packages
- `internet/_main.yml` - Internet tools and remote desktop clients
- `multimedia/_main.yml` - Media codecs and GStreamer plugins
- `posix/_main.yml` - Network mounts, fstab, POSIX system tasks (tagged: `posix`, `fstab`)
- `virtualization/_main.yml` - libvirt, KVM, QEMU, virt-manager
- `gnome/_main.yml` - GNOME desktop environment (runs only on GNOME systems)

## Environment Variables

The role uses the following environment variables for sensitive data:

| Variable | Purpose |
|----------|---------|
| `ALMIR_SSH_PRIV_KEY` | Private SSH key content |
| `ALMIR_SSH_PUB_KEY` | Public SSH key content |
| `ALMIR_SMB_USR` | SMB/CIFS username |
| `ALMIR_SMB_PWD` | SMB/CIFS password |

Set these before running the playbook:

```bash
export ALMIR_SSH_PRIV_KEY="$(cat ~/.ssh/id_rsa)"
export ALMIR_SSH_PUB_KEY="$(cat ~/.ssh/id_rsa.pub)"
export ALMIR_SMB_USR="your_smb_username"
export ALMIR_SMB_PWD="your_smb_password"
```

## Dependencies

This role has no hard dependencies, but may optionally use:

- `brcak_zmaj.almir_ansible.debloat` - Remove bloatware from workstations
- `geerlingguy.docker` - Docker Setup

Other compatible roles (external Galaxy roles):

- `geerlingguy.ansible` - Ansible installation
- `ecgalaxy.vscode` - VS Code IDE setup

## Installation

This role is part of the `brcak_zmaj.almir_ansible` collection:

```bash
ansible-galaxy collection install brcak_zmaj.almir_ansible
```
## Example Playbook

### Basic Setup (All Features Enabled)

```yaml
---
- name: Setup Development Workstation
  hosts: localhost
  gather_facts: true
  become: true

  roles:
    - role: brcak_zmaj.almir_ansible.my_pc_setup
```

### Run Specific Tasks Only

```bash
# Update packages and install multimedia codecs only
ansible-playbook playbook.yml --tags "package_mgmt,multimedia"

# Configure POSIX system and fstab only
ansible-playbook playbook.yml --tags "posix,fstab"

# Development tools only
ansible-playbook playbook.yml --tags "dev"
```

## Running the Role

### From Command Line

```bash
# Set required environment variables
export ALMIR_SSH_PRIV_KEY="$(cat ~/.ssh/id_rsa)"
export ALMIR_SSH_PUB_KEY="$(cat ~/.ssh/id_rsa.pub)"
export ALMIR_SMB_USR="domain\username"
export ALMIR_SMB_PWD="password"

# Run playbook
ansible-playbook -i inventory.ini my_playbook.yml -K
```

## OS-Specific Behavior

### Debian/Ubuntu

- Uses `remmina_debian_pkgs` for remote desktop client
- Uses `nodejs_npm_packages_debian` for Node.js installation
- Uses `gstreamer_debian_packages` for media codecs

### RHEL/Fedora

- Uses `remmina_redhat_pkgs` for remote desktop client
- Uses `nodejs_npm_packages_redhat` for Node.js installation
- Uses `gstreamer_redhat_packages` for media codecs
- Includes automatic desktop environment detection (GNOME/KDE)

## Variables Files in `/vars`

- `packages.yml` - Package definitions per OS
- `flatpak_vars.yml` - Flatpak applications list
- `bash_alias.yml` - Bash aliases for the user
- `main.yml` - Main variable file

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
