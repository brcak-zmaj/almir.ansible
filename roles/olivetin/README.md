<div align = "center">
  <img alt = "project logo" src = "https://github.com/OliveTin/OliveTin/blob/main/frontend/OliveTinLogo.png" width = "128" />
  <h1>OliveTin</h1>

  OliveTin gives **safe** and **simple** access to predefined shell commands from a web interface.

# Ansible Role - OliveTin

A comprehensive Ansible role for deploying OliveTin on RedHat and Debian-based systems with support for both package manager and Docker installation methods.

## Overview

OliveTin is a web-based interface for running Linux shell commands. This role automates the installation and configuration of OliveTin on Linux systems, providing a simple way to execute shell commands through a web interface.

## Features

### Installation Methods
- **Package Manager**: Install via RPM (Fedora/Redhat) or DEB (Debian/Ubuntu) packages
- **Docker**: Deploy as Docker container with network and volume configuration

### Configuration Management
- **Default Configuration**: Automatically deploys a basic example configuration
- **Custom Configuration**: Override with your own config file path
- **Version Control**: Pin to specific versions or use latest releases

### Service Management
- **Systemd Integration**: Automatic service enablement and startup (package install)
- **Firewall Configuration**: Use `geerlingguy.firewall` role or similar for firewall setup

### Docker Features
- **Network Isolation**: Creates dedicated Docker network
- **Volume Management**: Configurable volume mounts for configuration and Docker socket access
- **Resource Limits**: Configurable memory and CPU limits

## Requirements

### Ansible Version Compatibility

This role is tested and supported with:
- **Ansible**: `>= 2.9`
- **Python**: `>= 3.6` (on target system)

### Target System Requirements

- **OS**: Fedora Linux or Debian-based Linux (Debian, Ubuntu)
- **Access**: SSH access with sudo/root privileges
- **Python**: Python 3 installed on target system

### Dependencies

- **For Docker installation**: Docker must be installed (recommend using `geerlingguy.docker` role)
- **For firewall configuration**: Use `geerlingguy.firewall` role or similar
- **community.docker**: Required for Docker container management (install via `ansible-galaxy collection install community.docker`)

## Installation

This role is part of the `brcak_zmaj.almir_ansible` collection. Install the collection:

```bash
ansible-galaxy collection install brcak_zmaj.almir_ansible
```

Or use the role directly:

```bash
ansible-galaxy install almir.olivetin
```

## Role Variables

### Installation Method

| Variable Name | Description | Default Value |
|---------------|-------------|---------------|
| `olivetin_install_method` | Installation method: `package` or `docker` | `package` |

### Version Control

| Variable Name | Description | Default Value |
|---------------|-------------|---------------|
| `olivetin_version` | Package version (use `latest` for latest release) | `latest` |
| `olivetin_docker_version` | Docker image version/tag | `latest` |

### Configuration Management

| Variable Name | Description | Default Value |
|---------------|-------------|---------------|
| `olivetin_config_path` | Custom config file path (null = use role template) | `null` |
| `olivetin_config_dir` | Directory where config file is placed | `/etc/OliveTin` |

### Package Manager Installation

| Variable Name | Description | Default Value |
|---------------|-------------|---------------|
| `olivetin_package_url_fedora` | Fedora RPM package URL | GitHub latest release |
| `olivetin_package_url_debian` | Debian DEB package URL | GitHub latest release |
| `olivetin_service_enabled` | Enable systemd service | `true` |
| `olivetin_service_state` | Service state (started/stopped) | `started` |
| `olivetin_port` | Web interface port | `1337` |
| `olivetin_uninstall` | Uninstall and purge OliveTin | `false` |

### Docker Installation

| Variable Name | Description | Default Value |
|---------------|-------------|---------------|
| `olivetin_docker_network_name` | Docker network name | `olivetin_network` |
| `olivetin_docker_network_create` | Create network if it doesn't exist | `true` |
| `olivetin_docker_image` | Docker image | `jamesread/olivetin` |
| `olivetin_docker_container_name` | Container name | `olivetin` |
| `olivetin_docker_port` | Host port mapping | `1337` |
| `olivetin_docker_memory` | Container memory limit | `512m` |
| `olivetin_docker_cpus` | Container CPU limit | `1` |
| `olivetin_docker_restart_policy` | Container restart policy | `unless-stopped` |
| `olivetin_docker_user` | Container user (root for Docker socket access) | `root` |
| `olivetin_docker_config_path` | Host path for config directory | `/docker/OliveTin` |
| `olivetin_docker_config_mount` | Config volume mount | `{{ olivetin_docker_config_path }}:/config` |
| `olivetin_docker_sock_mount` | Docker socket mount | `/var/run/docker.sock:/var/run/docker.sock` |
| `olivetin_docker_env` | Additional environment variables | `{}` |

## Dependencies

- **For Docker**: `geerlingguy.docker` role (recommended) or Docker must be installed manually
- **community.docker**: Required for Docker container management

## Example Playbooks

### Basic Package Installation (Fedora)

```yaml
---
- name: Install OliveTin via package manager
  hosts: fedora_server
  become: true
  roles:
    - role: almir.olivetin
  vars:
    olivetin_install_method: package
    olivetin_port: 1337
```

### Docker Installation

```yaml
---
- name: Install OliveTin via Docker
  hosts: docker_server
  become: true
  roles:
    - role: geerlingguy.docker  # Install Docker first
    - role: almir.olivetin
  vars:
    olivetin_install_method: docker
    olivetin_docker_port: 1337
    olivetin_docker_memory: "1g"
    olivetin_docker_cpus: 2
    olivetin_docker_config_path: /opt/docker/olivetin
```

### Specific Version Installation

```yaml
---
- name: Install specific OliveTin version
  hosts: olivetin_server
  become: true
  roles:
    - role: almir.olivetin
  vars:
    olivetin_install_method: package
    olivetin_version: v3.0.0  # Pin to specific version
```

## Post-Installation

### Accessing OliveTin

After installation, access OliveTin at:
- **URL**: `http://your-server-ip:1337`
- **Port**: Default is `1337` (configurable via `olivetin_port`)

### Configuration

The default configuration file is located at:
- **Package install**: `/etc/OliveTin/config.yaml`
- **Docker install**: `{{ olivetin_docker_config_path }}/config.yaml`

### Basic Configuration Example

The role deploys a basic example configuration:

```yaml
actions:
  - title: "Hello world!"
    shell: echo 'Hello World!'
```

For advanced configuration options, see the [OliveTin Documentation](https://docs.olivetin.app/configuration/).

### Service Management (Package Install)

```bash
# Check service status
sudo systemctl status OliveTin

# View logs
sudo journalctl -eu OliveTin

# Restart service
sudo systemctl restart OliveTin
```

### Docker Container Management

```bash
# Check container status
docker ps | grep olivetin

# View container logs
docker logs olivetin

# Restart container
docker restart olivetin
```

### Config File Updates

To update the OliveTin configuration without reinstalling:

```yaml
- hosts: olivetin_servers
  become: true
  roles:
    - role: almir.olivetin
  vars:
    olivetin_install_method: package  # or docker
  tags:
    - update_config
```

This will only run the configuration deployment tasks and restart the appropriate service/container.

### Uninstall OliveTin

To completely remove OliveTin and all its configuration:

```yaml
- hosts: olivetin_servers
  become: true
  roles:
    - role: almir.olivetin
  vars:
    olivetin_uninstall: true
    olivetin_install_method: package  # or docker
```

This will:
- Stop and remove the service/container
- Remove the package or Docker container
- Delete configuration files and directories

### Firewall Configuration

Use the `geerlingguy.firewall` role or similar for firewall configuration:

```yaml
- hosts: servers
  become: true
  roles:
    - role: geerlingguy.firewall
      vars:
        firewall_allowed_tcp_ports:
          - "{{ olivetin_port }}"
    - role: almir.olivetin
```

### Using Existing Docker Network

If you want to use an existing Docker network:

```yaml
olivetin_docker_network_name: existing_network
olivetin_docker_network_create: false
```

## Troubleshooting

### Service Won't Start (Package Install)

Check the service status and logs:

```bash
sudo systemctl status OliveTin
sudo journalctl -eu OliveTin
```

Common issues:
- Missing configuration file: Ensure `/etc/OliveTin/config.yaml` exists
- Invalid YAML syntax: Validate your configuration file
- Port already in use: Change `olivetin_port` to a different port

### Docker Container Issues

Check container logs:

```bash
docker logs olivetin
```

Common issues:
- Docker socket permission: Container runs as root by default for Docker socket access
- Network issues: Ensure Docker network exists or set `olivetin_docker_network_create: true`
- Volume mount issues: Ensure config directory exists and has correct permissions

### Firewall Issues

Use the `geerlingguy.firewall` role (or similar) for firewall configuration:

```yaml
- hosts: servers
  become: true
  roles:
    - role: geerlingguy.firewall
      vars:
        firewall_allowed_tcp_ports:
          - "{{ olivetin_port }}"
    - role: almir.olivetin
```

## Security Considerations

### Docker Installation

- The Docker container runs as `root` by default to access the Docker socket
- This is required for Docker control features
- Consider security implications in production environments
- See [OliveTin Docker Documentation](https://docs.olivetin.app/install/docker_compose.html) for alternatives

### Firewall

- Use `geerlingguy.firewall` role or similar to configure firewall rules for port 1337
- Consider restricting access to specific IPs or networks
- Use a reverse proxy (Nginx, Apache, Caddy) for production deployments

### Configuration File

- Ensure configuration file has appropriate permissions (644, root:root)
- Review actions carefully before deployment
- Use OliveTin's access control features for multi-user environments

## Idempotency

This role is fully idempotent. All tasks use proper Ansible modules and include state checks to ensure safe re-execution. Existing configurations and data are preserved.

## Notes

- **Default Behavior**: Installs via package manager unless `olivetin_install_method: docker` is set
- **Configuration**: Uses role template by default, override with `olivetin_config_path`
- **Version Control**: Use `latest` for latest releases or pin to specific versions
- **Docker Dependencies**: Docker installation requires `geerlingguy.docker` role or manual Docker setup
- **Firewall**: Automatically configures firewall rules (can be disabled)

## References

- [OliveTin Official Documentation](https://docs.olivetin.app/)
- [OliveTin GitHub Repository](https://github.com/OliveTin/OliveTin)
- [Fedora Installation Guide](https://docs.olivetin.app/install/linux_fedora.html)
- [Debian Installation Guide](https://docs.olivetin.app/install/linux_deb.html)
- [Docker Compose Guide](https://docs.olivetin.app/install/docker_compose.html)

## Author Information

- Almir Zohorovic