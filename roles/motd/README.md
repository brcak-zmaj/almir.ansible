# Ansible Role - motd

A simple role to manage the system Message of the Day (MOTD) by deploying a configurable Jinja2 template to the target host.

## Overview

This role places a template-rendered banner at the configured MOTD path (default: `/etc/motd`). It is idempotent and uses variables for path, permissions, ownership, and template source.

## Installation

```bash
ansible-galaxy collection install brcak_zmaj.almir_ansible
```

## Role Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `motd_path` | `/etc/motd` | Destination path for the MOTD file |
| `motd_mode` | `0644` | File permissions for the MOTD file |
| `motd_owner` | `root` | File owner |
| `motd_group` | `root` | File group |
| `motd_template_src` | `motd.j2` | Template source file located in `templates/` |

## Supported Platforms

| OS Family | Tested Versions |
|-----------|-----------------|
| Debian    | Ubuntu 20.04+, Debian 11+ |
| RedHat    | RHEL 8+, Rocky 8+, Fedora 35+ |

## Example Playbook

```yaml
---
- name: Deploy MOTD banner
  hosts: all
  become: true

  roles:
    - role: brcak_zmaj.almir_ansible.motd
      vars:
        motd_path: "/etc/motd"
        motd_owner: "root"
        motd_group: "root"
        motd_mode: "0644"
        motd_template_src: "motd.j2"
```

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
