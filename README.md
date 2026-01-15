<img src="https://raw.githubusercontent.com/geerlingguy/mac-dev-playbook/master/files/Mac-Dev-Playbook-Logo.png" width="250" height="156" alt="Playbook Logo" />

# Ansible Collection for Brcak Zmaj - Almir

[![Ansible Collection](https://img.shields.io/badge/brcak.zmaj-brightgreen)](https://galaxy.ansible.com/ui/repo/published/brcak_zmaj/almir_ansible)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/brcak-zmaj/almir.ansible)](https://github.com/brcak-zmaj/almir.ansible/commits)
[![GitHub Contributors](https://img.shields.io/github/contributors/brcak-zmaj/almir.ansible)](https://github.com/brcak-zmaj/almir.ansible/graphs/contributors)

## Ansible Version Compatibility

The collection is tested and supported with: `ansible >= 2.9`

## Installing the Collection

```shell
ansible-galaxy collection install brcak_zmaj.almir_ansible
```

## Roles Included in the Collection

### System Management & Tuning

| Role | Description |
|------|-------------|
| `mullvad_browser` | Is a privacy-focused web browser developed in collaboration between Mullvad VPN and the Tor Project |
| `debloat` | Removes unnecessary packages and bloatware from Linux distributions |
| `my_pc_setup` | Configures development workstations with packages, mountpoints, and appearance |
| `pc_tuning` | System tuning and kernel optimization for desktops/workstations |
| `cifs_utils` | Manages CIFS/SMB mount utilities for network file sharing |
| `zram` | Configures compressed RAM swap using systemd zram-generator |

### Database Tuning

| Role | Description |
|------|-------------|
| `mysql_tuning` | Kernel parameter optimization for MySQL database servers |
| `postgresql_tuning` | Kernel parameter optimization for PostgreSQL database servers |

### Container & Virtualization

| Role | Description |
|------|-------------|
| `docker_tuning` | Sysctl parameter optimization for Docker container hosts |
| `proxmox` | Comprehensive Proxmox VE configuration including ZFS tuning and GPU passthrough |
| `proxmox_restore_snapshot` | Restore Proxmox snapshots in playbooks |
| `virtualbox` | Installs and configures VirtualBox virtualization software |

### Monitoring & Exporters

| Role | Description |
|------|-------------|
| `netdata` | Deploys Netdata monitoring agent with alerting and notifications |
| `nvidia_exporter` | NVIDIA GPU metrics exporter for Prometheus |
| `NUT` | Network UPS Tools for UPS monitoring and automated shutdown |

### Application Deployment

| Role | Description |
|------|-------------|
| `google_earth` | Installs Google Earth on target systems |
| `olivetin` | Web-based interface for running Linux shell commands |
| `kiwix` | Kiwix offline content server with ZIM file management |
| `astral_uv` | Fast Python package manager written in Rust |

### Embedded & IoT

| Role | Description |
|------|-------------|
| `raspberry_pi` | Comprehensive Raspberry Pi configuration (3, 4, 5) |

### Geospatial

| Role | Description |
|------|-------------|
| `geospatial_data` | Installs QGIS, Marble, Viking and downloads offline map datasets |

## Contributing

Contributions are welcome via GitHub pull requests and issues:

- Submit bugs and feature requests
- Review and submit source code changes
- Add new roles and modules

## License

GPL-3.0-or-later

> Note: This is my personal repository. The license you receive is from me, not my employer. These are "shortened" versions of my personal roles - contact ansible@th2h2f0rt1.33mail.com for full versions or custom roles.

## Support

For issues, questions, or contributions, please use the [GitHub Issues](https://github.com/brcak-zmaj/almir.ansible/issues) page.


## Stats

![Alt](https://repobeats.axiom.co/api/embed/7a7fe37d43ef2cab7bdbc23ba8c5cfe3cfbdf832.svg "Repobeats analytics image")