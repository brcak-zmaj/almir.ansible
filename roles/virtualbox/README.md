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

## Playbook

```yaml
- name: Install VirtualBox
  hosts: all
  become: true
  vars:

  roles:
    - role: almir.ansible.virtualbox
```

## Author Information

-   [Almir Zohorovic](https://github.com/brcak-zmaj)