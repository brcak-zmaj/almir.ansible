<img src="https://raw.githubusercontent.com/geerlingguy/mac-dev-playbook/master/files/Mac-Dev-Playbook-Logo.png" width="250" height="156" alt="Playbook Logo" /> <img src="https://upload.wikimedia.org/wikipedia/commons/d/d5/Virtualbox_logo.png" width="250" height="156" alt="Virtualbox Logo" />



## Ansible role - VirtualBox

This ansible role will Install virtualbox on targets

## Requirements

- Ansible 2.13+

## Role Variables

| Variable Name         | Description                                                          | Default Value                                                       |
|-----------------------|----------------------------------------------------------------------|---------------------------------------------------------------------|
| `virtual_box_key_url`  | Contains variable for virtualbox asc key.                           | `https://www.virtualbox.org/download/oracle_vbox_2016.asc` |
| `virtual_box_repo`      | Virtualbox Repository. | `deb https://download.virtualbox.org/virtualbox/debian buster contrib` |
| `virtualbox_packages`      | Virtualbox packages.    | `virtualbox, virtualbox-dkms,...` |


## Dependencies

No Dependencies


## Installation

This role is part of the `brcak_zmaj.almir_ansible` collection. Install the collection:

```bash
ansible-galaxy collection install brcak_zmaj.almir_ansible
```
## Playbook

```yaml
- name: Install VirtualBox
  hosts: all
  become: true
  vars:

  roles:
    - role: brcak_zmaj.almir_ansible.virtualbox
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
