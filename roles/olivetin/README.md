<p align="center">
<a href="https://www.netdata.cloud#gh-light-mode-only">
  <img src="https://www.netdata.cloud/img/readme-images/netdata_readme_logo_light.png" alt="Netdata" width="300"/>
</a>
<a href="https://www.netdata.cloud#gh-dark-mode-only">
  <img src="https://www.netdata.cloud/img/readme-images/netdata_readme_logo_dark.png" alt="Netdata" width="300"/>
</a>
</p>
<h3 align="center">X-Ray Vision for your infrastructure!</h3>


# OliveTin Ansible Role

Lightweight Ansible role to install and configure OliveTin via package or Docker.

This README provides the minimum usage and variables needed to run the role in a playbook or as part of the `brcak_zmaj.almir_ansible` collection.

## Quick Start

Package install (default):

```yaml
- hosts: servers
  become: true
  roles:
    - role: almir.olivetin
      vars:
        olivetin_install_method: package
```

Docker install:

```yaml
- hosts: servers
  become: true
  roles:
    - role: geerlingguy.docker  # ensure docker present
    - role: almir.olivetin
      vars:
        olivetin_install_method: docker
        olivetin_docker_config_path: /opt/olivetin
```

## Important Variables (defaults in `defaults/main.yml`)

- `olivetin_install_method`: `package` or `docker` (default: `package`)
- `olivetin_config_path`: custom config file path (empty string = use role template)
- `olivetin_config_dir`: `/etc/OliveTin` (package)
- `olivetin_docker_config_path`: `/docker/OliveTin` (docker)
- `olivetin_docker_image`: Docker image name (default: `jamesread/olivetin`)
- `olivetin_docker_container_name`: container name (default: `olivetin`)
- `olivetin_port`: HTTP port (default: `1337`)

For a complete list see `defaults/main.yml`.

## Admin Password Behavior

The role builds `olivetin_users` and hashes passwords on the control node before writing the config. The admin password can be provided via:

- Control-node environment variable:

```bash
export OLIVETIN_ADMIN_PASSWORD='mysecret'
ansible-playbook play.yml
```

- Or by passing `olivetin_users` with `--extra-vars`:

```bash
ansible-playbook play.yml --extra-vars 'olivetin_users=[{"username":"admin","usergroup":"admins","password":"mysecret"}]'
```

When the role runs it will hash the provided password and write it into the config file.

## Using in a Collection

If you're using this role as part of the `brcak_zmaj.almir_ansible` collection:

```bash
ansible-galaxy collection install brcak_zmaj.almir_ansible
```

Then reference it in your playbook as:

```yaml
- hosts: servers
  become: true
  roles:
    - role: brcak_zmaj.almir_ansible.almir.olivetin
```

## Paths

- Package config: `/etc/OliveTin/config.yaml`
- Docker config: `<olivetin_docker_config_path>/config.yaml`

## Service

Package installs use a `systemd` service named `OliveTin` (case-sensitive). Use `sudo systemctl status OliveTin` to check.

## Cleanup

This role allows to uninstall and cleanup when `olivetin_uninstall: true` is set.

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