<img src="https://raw.githubusercontent.com/geerlingguy/mac-dev-playbook/master/files/Mac-Dev-Playbook-Logo.png" width="250" height="156" alt="Playbook Logo" />

## Ansible role - Brave Browser

This ansible role will setup and install Brave Browser

## Requirements

- Ansible 2.13+

## Role Variables

| Variable Name         | Description                                                          | Default Value                                                       |
|-----------------------|----------------------------------------------------------------------|---------------------------------------------------------------------|
| `brave_repo`           | This is what will go inside of the repo. | `deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main` |
| `brave_baseurl`        | URL Where the gpg key will come from.    | `https://brave-browser-rpm-release.s3.brave.com/x86_64/` |
| `brave_gpgkey`         | URL where the ASC Key will come from.    | `https://brave-browser-rpm-release.s3.brave.com/brave-core.asc` |
| `brave_keyring`        | URL where the GPG Key will come from.    | `https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg` |
| `brave_pkg_name`       | Name of the Brave Browser package.       | `brave-browser` |

## Dependencies

No Dependencies

## Installation

This role is part of the `brcak_zmaj.almir_ansible` collection. Install the collection:

```bash
ansible-galaxy collection install brcak_zmaj.almir_ansible
```

## Playbook

```yaml
- name: Setup Brave Browser
  hosts: workstation
  become: true
  vars:

  roles:
    - role: brcak_zmaj.almir_ansible.brave_browser
```

## Author Information

-   [Almir Zohorovic](https://github.com/brcak-zmaj)