<img src="https://raw.githubusercontent.com/geerlingguy/mac-dev-playbook/master/files/Mac-Dev-Playbook-Logo.png" width="250" height="156" alt="Playbook Logo" /> 



## Ansible role - cifs utils 

This ansible role will Install cifs-utils on targets

## Requirements

- Ansible 2.13+

## Role Variables

| Variable Name         | Description                                                          | Default Value                                                       |
|-----------------------|----------------------------------------------------------------------|---------------------------------------------------------------------|
| ``  |                            | `` |


## Dependencies

No Dependencies


## Installation

This role is part of the `brcak_zmaj.almir_ansible` collection. Install the collection:

```bash
ansible-galaxy collection install brcak_zmaj.almir_ansible
```
## Playbook

```yaml
- name: Install cifs-utils
  hosts: all
  become: true
  vars:

  roles:
    - role: almir_ansible.cifs-utils
```

## Author Information

-   [Almir Zohorovic](https://github.com/brcak-zmaj)
## Stats

![Alt](https://repobeats.axiom.co/api/embed/7a7fe37d43ef2cab7bdbc23ba8c5cfe3cfbdf832.svg "Repobeats analytics image")
