# mysql_tuning

Mysql Tuning role for Ansible collection

## Requirements

None

## Role Variables

See `defaults/main.yml` for available variables.

## Installation

This role is part of the `brcak_zmaj.almir_ansible` collection. Install the collection:

```bash
ansible-galaxy collection install brcak_zmaj.almir_ansible
```

## Example Playbook

```yaml
- hosts: servers
  roles:
    - role: brcak_zmaj.almir_ansible.mysql_tuning
```

## License

GPL-3.0-or-later

## Author Information

Almir Zohorovic
