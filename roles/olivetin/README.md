<p align="center">
  <img src="https://www.olivetin.app/images/logo.svg" alt="OliveTin" width="300"/>
</p>
<h3 align="center">Safe and simple access to predefined shell commands from a web interface</h3>


# Ansible Role - OliveTin

Lightweight Ansible role to install and configure OliveTin via package or Docker.

This README provides the minimum usage and variables needed to run the role in a playbook or as part of the `brcak_zmaj.almir_ansible` collection.

## Quick Start

Package install (default):

```yaml
- hosts: servers
  become: true
  roles:
    - role: brcak_zmaj.almir_ansible.olivetin
      vars:
        olivetin_install_method: package
```

Docker install:

```yaml
- hosts: servers
  become: true
  roles:
    - role: geerlingguy.docker  # ensure docker present
    - role: brcak_zmaj.almir_ansible.olivetin
      vars:
        olivetin_install_method: docker
        olivetin_docker_config_path: /opt/olivetin
```

Docker installs also require the `community.docker` collection (declared as a
collection dependency in `galaxy.yml`, so `ansible-galaxy collection install
brcak_zmaj.almir_ansible` pulls it in automatically).

## Important Variables (defaults in `defaults/main.yml`)

- `olivetin_install_method`: `package` or `docker` (default: `package`)
- `olivetin_version`: `latest`, or a pinned release tag (e.g. `3000.19.0` —
  OliveTin's tags are not "v"-prefixed). Package installs detect
  `ansible_facts['architecture']` automatically (amd64/arm64/armv5/armv6/armv7/riscv64)
  and, when pinned, skip the download/reinstall entirely if that exact
  version is already installed.
- `olivetin_config_path`: custom config file path (empty string = use role template)
- `olivetin_config_dir`: `/etc/OliveTin` (package)
- `olivetin_config_d_enabled`: `true` — adds `include: config.d` to the
  rendered config so you (or the optional Semaphore integration below) can
  drop in extra actions without ever touching the main config file.
- `olivetin_docker_config_path`: `/docker/OliveTin` (docker)
- `olivetin_docker_image`: Docker image name (default: `jamesread/olivetin`)
- `olivetin_docker_container_name`: container name (default: `olivetin`)
- `olivetin_docker_mount_socket`: `true` — mounts `/var/run/docker.sock` into
  the container for Docker-controlling actions. Combined with the container
  running as root, this is full root-equivalent host access — set to `false`
  if you don't need Docker-controlling actions.
- `olivetin_port`: HTTP port (default: `1337`)

For a complete list see `defaults/main.yml`.

## Extending the config without editing it (`config.d`)

OliveTin supports splitting its config across a directory
(`include: config.d` — see [reference/includes](https://docs.olivetin.app/reference/includes.html)),
and `actions:` lists **merge** across every file found there (other keys like
`dashboards`/`accessControlLists` are overwritten by whichever file loads
last, so keep those in your main config). This role creates `config.d/` next
to the config file and references it automatically, so:

- You can drop your own action files into `config.d/` (by hand, or from your
  own automation) and they'll show up alongside — never replacing — anything
  else, including this role's own default demo actions.
- The optional Semaphore integration below writes to exactly one file there
  (`config.d/50-semaphore-actions.yaml`) and touches nothing else.
- Actions are live-reloaded by OliveTin — no restart needed after adding a
  `config.d` file (a browser refresh is enough to see new buttons).

Set `olivetin_config_d_enabled: false` to disable this (only relevant if
you're also using `olivetin_config_path` to fully replace the config
yourself).

## Admin Password Behavior

The role hashes passwords with **Argon2id** — the algorithm OliveTin requires
for local users ([docs](https://docs.olivetin.app/security/local.html)) —
on the **target host** (not the control node; the required Python packages
are installed there automatically by this role). Hashing is idempotent: an
unchanged password reuses its previously-generated hash (cached under
`olivetin_state_dir`) instead of generating a new salt — and therefore a
"changed" config and service restart — on every single run.

The admin password can be provided via:

- Control-node environment variable:

```bash
export OLIVETIN_ADMIN_PASSWORD='mysecret'
ansible-playbook play.yml
```

- Or by passing `olivetin_users` with `--extra-vars`:

```bash
ansible-playbook play.yml --extra-vars 'olivetin_users=[{"username":"admin","usergroup":"admins","password":"mysecret"}]'
```

## Optional: Semaphore Integration

Auto-generates OliveTin buttons from [Ansible Semaphore](https://semaphoreui.com)
task templates in a project, kept in sync by a scheduled script (a systemd
timer on the target host — no Docker required for this part regardless of
`olivetin_install_method`). A button calls Semaphore's REST API to start the
matching task; nothing more.

This is entirely **opt-in** (`olivetin_semaphore_integration_enabled: false`
by default) and additive — see [Extending the config](#extending-the-config-without-editing-it-configd)
above for why enabling it never touches actions you define yourself.

```yaml
- hosts: servers
  become: true
  roles:
    - role: brcak_zmaj.almir_ansible.olivetin
      vars:
        olivetin_semaphore_integration_enabled: true
        olivetin_semaphore_url: "http://semaphore.example.com:3000"
        # Never hardcode secrets in a playbook committed to source control —
        # this role deliberately does not read env vars/vault itself, so
        # however you manage secrets normally is up to you:
        olivetin_semaphore_api_token: "{{ lookup('env', 'SEMAPHORE_API_TOKEN') }}"
        olivetin_semaphore_project_id: "1"
        # Every template in the project becomes a button EXCEPT these IDs —
        # review your project before enabling with an empty blocklist.
        olivetin_semaphore_blocklist_ids: [12, 34]
```

Key variables (all in `defaults/main.yml`, prefixed `olivetin_semaphore_`):

| Variable | Default | Purpose |
|---|---|---|
| `olivetin_semaphore_integration_enabled` | `false` | Master toggle |
| `olivetin_semaphore_url` | `""` | Semaphore base URL, no trailing slash. Required when enabled. |
| `olivetin_semaphore_api_token` | `""` | Bearer token (Semaphore UI → user menu → API Tokens). Required when enabled. Always `no_log`'d regardless of `olivetin_no_log_passwords`. |
| `olivetin_semaphore_project_id` | `""` | Which Semaphore project to scrape. Required when enabled. |
| `olivetin_semaphore_blocklist_ids` | `[]` | Template IDs to exclude. Empty = every template in the project gets a button. |
| `olivetin_semaphore_action_acl` | `["admins"]` | ACL name(s) applied to every generated action (must exist in `olivetin_access_control_lists`) |
| `olivetin_semaphore_action_confirm` | `true` | Require a confirmation click before running |
| `olivetin_semaphore_scraper_interval` | `"5min"` | systemd `OnUnitActiveSec=` value |
| `olivetin_semaphore_scraper_script_path` | `""` (auto) | Where the script is installed — defaults next to the OliveTin config dir |
| `olivetin_semaphore_scraper_output_file` | `""` (auto) | Generated actions file — defaults to `config.d/50-semaphore-actions.yaml` |
| `olivetin_semaphore_scraper_template` | `semaphore-scraper.sh.j2` | Override with your own Jinja2 template for different scraping/filtering logic |

**Security model:** the token is written once to a root-only (`0600`) env
file, never into the generated actions file itself. Both OliveTin's own
service (via a systemd drop-in, so button clicks at run-time can reach
Semaphore) and the scraper service source that same file via
`EnvironmentFile=`. Review `templates/semaphore-scraper.sh.j2` before
enabling this against a Semaphore project with destructive templates
(Terraform destroys, cluster patching, etc.) — the blocklist is your
responsibility to populate.

Disabling the role (`olivetin_uninstall: true`) also removes the scraper's
systemd units and the Docker-service drop-in.

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
    - role: brcak_zmaj.almir_ansible.olivetin
```

## Paths

- Package config: `/etc/OliveTin/config.yaml` (+ `config.d/`)
- Docker config: `<olivetin_docker_config_path>/config.yaml` (+ `config.d/`)

## Service

Package installs use a `systemd` service named `OliveTin` (case-sensitive).
Use `sudo systemctl status OliveTin` to check. Note the underlying package
itself is named lowercase `olivetin` (`dpkg -l | grep olivetin` /
`rpm -q olivetin`) — only the service/binary/release-asset names use the
`OliveTin` capitalization.

## Cleanup

This role allows to uninstall and cleanup when `olivetin_uninstall: true` is set.

## Security Considerations

### Docker Installation

- The Docker container runs as `root` by default to access the Docker socket
- `olivetin_docker_mount_socket: true` by default mounts the Docker socket for
  Docker-controlling actions — combined with running as root, this is
  effectively full host root access from inside the container. Set to
  `false` if you don't need it.
- See [OliveTin Docker Documentation](https://docs.olivetin.app/install/docker_compose.html) for alternatives

### Firewall

This role does **not** configure any firewall rules. Use
`geerlingguy.firewall` or similar to restrict access to port 1337 (or your
`olivetin_port`) to trusted networks, and consider a reverse proxy (Nginx,
Apache, Caddy) with TLS for anything beyond a trusted LAN.

### Configuration File

- Ensure configuration file has appropriate permissions (644, root:root)
- Review actions carefully before deployment
- Use OliveTin's access control features for multi-user environments

## Notes

- **Default Behavior**: Installs via package manager unless `olivetin_install_method: docker` is set
- **Configuration**: Uses role template by default, override with `olivetin_config_path`
- **Version Control**: Use `latest` for the newest release, or pin an exact release tag
- **Docker Dependencies**: Docker installation requires the `community.docker` collection (declared as a collection dependency) and either `geerlingguy.docker` or a manually-provisioned Docker install

## References

- [OliveTin Official Documentation](https://docs.olivetin.app/)
- [OliveTin GitHub Repository](https://github.com/OliveTin/OliveTin)
- [Fedora Installation Guide](https://docs.olivetin.app/install/linux_fedora.html)
- [Debian Installation Guide](https://docs.olivetin.app/install/linux_deb.html)
- [Docker Compose Guide](https://docs.olivetin.app/install/docker_compose.html)
- [Config Includes (config.d)](https://docs.olivetin.app/reference/includes.html)
- [Local User Authentication](https://docs.olivetin.app/security/local.html)
- [Semaphore UI](https://semaphoreui.com) / [Semaphore API](https://docs.semui.co/administration-guide/api)

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
