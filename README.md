<img src="https://raw.githubusercontent.com/geerlingguy/mac-dev-playbook/master/files/Mac-Dev-Playbook-Logo.png" width="250" height="156" alt="Playbook Logo" />

# Ansible Collection for Brcak Zmaj - Almir 

[![Ansible Collection](https://img.shields.io/badge/brcak.zmaj-brightgreen)](https://galaxy.ansible.com/ui/repo/published/brcak_zmaj/almir_ansible)
[![GitHub release](https://img.shields.io/github/v/release/brcak-zmaj/almir.ansible.svg)](https://github.com/brcak-zmaj/almir.ansible/releases)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/brcak-zmaj/almir.ansible)](https://github.com/brcak-zmaj/almir.ansible/commits)
[![GitHub Contributors](https://img.shields.io/github/contributors/brcak-zmaj/almir.ansible)](https://github.com/brcak-zmaj/almir.ansible/graphs/contributors)


## Ansible version compatibility

The collection is tested and supported with: `ansible >= 2.9`

## Installing the collection

Install the collection using the command below:

```shell
ansible-galaxy collection install brcak_zmaj.almir_ansible
```

## Roles included in the collection

This collection includes the following roles for server management, system optimization, and application deployment:

### System Management
- **brave_browser**: Installs and configures Brave Web Browser on your target hosts.
- **cifs_utils**: Configures CIFS/SMB mount utilities for network file sharing.
- **debloat**: Removes unnecessary packages, bloatware, and system components from Linux distributions (Fedora, RHEL, CentOS, Debian, Ubuntu).
- **my_pc_setup**: Configures and sets up development workstations. Installs packages, sets up mountpoints, and configures appearance.
- **pc_tuning**: System tuning and optimization for desktop/workstation systems.
- **virtualbox**: Installs and configures VirtualBox virtualization software.

### Database Tuning
- **mysql_tuning**: Configures various sysctl parameters to optimize servers running MySQL.
- **postgresql_tuning**: Configures various sysctl parameters to optimize servers running PostgreSQL.

### Container & Virtualization
- **docker_tuning**: Configures various sysctl parameters to optimize servers running Docker containers.
- **proxmox**: Comprehensive configuration and optimization for Proxmox Virtual Environment (PVE) servers including repository management, ZFS tuning, GPU passthrough, backup configuration, and more.
- **proxmox_restore_snapshot**: Easy-to-use role for restoring Proxmox snapshots in playbooks.

### Monitoring & Exporters
- **nvidia_exporter**: Sets up NVIDIA GPU metrics exporter for Prometheus monitoring.

### Application Deployment
- **google_earth**: Installs and configures Google Earth on target systems.
- **olivetin**: Installs and configures OliveTin web-based interface for running Linux shell commands.

### Embedded Systems
- **raspberry_pi**: Comprehensive Ansible role for configuring Raspberry Pi 3, 4, and 5 devices with extensive configuration options for swap management, logging optimization, power management, boot settings, hardware interfaces, and system tuning.

### Geospatial
- **geospatial_data**: Installs geospatial software (QGIS, Marble, Viking) and downloads offline map datasets.

## Quick Start Examples

### Install a single role from the collection

```yaml
---
- hosts: all
  become: true
  roles:
    - role: brcak_zmaj.almir_ansible.debloat
```

### Install multiple roles

```yaml
---
- hosts: all
  become: true
  roles:
    - role: brcak_zmaj.almir_ansible.debloat
    - role: brcak_zmaj.almir_ansible.docker_tuning
    - role: brcak_zmaj.almir_ansible.mysql_tuning
```

## Contributing

I am accepting GitHub pull requests and issues. There are many ways in which you can participate in the codebase, for example:

-   Submit bugs and feature requests, and help me verify them
-   Submit and review source code changes in GitHub pull requests
-   Add new roles, modules, etc for more brcak-zmaj resources

## License

GPL-3.0-or-later

> Note: I am providing code in the repository to you under an open source license. Because this is my personal repository, the license you receive to my code is from me and not my employer. This repo contains "shortened" versions of my personal roles - If interested in full versions or custom roles please contact me at ansible@th2h2f0rt1.33mail.com 

## Stats

![Alt](https://repobeats.axiom.co/api/embed/7a7fe37d43ef2cab7bdbc23ba8c5cfe3cfbdf832.svg "Repobeats analytics image")
