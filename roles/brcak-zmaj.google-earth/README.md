<img src="https://raw.githubusercontent.com/geerlingguy/mac-dev-playbook/master/files/Mac-Dev-Playbook-Logo.png" width="250" height="156" alt="Playbook Logo" /> <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/e/e4/Google_Earth_icon.svg/120px-Google_Earth_icon.svg.png" width="250" height="156" alt="Google Earth Logo" />

## Ansible role - Google Earth

This ansible role will Install google-earth on targets

## Requirements

- Ansible 2.13+

## Role Variables

| Variable Name         | Description                                                          | Default Value                                                       |
|-----------------------|----------------------------------------------------------------------|---------------------------------------------------------------------|
| `earth_repo`          | Google Earth Repository.                           | `deb [signed-by=/etc/apt/trusted.gpg.d/google.gpg arch=amd64] http://dl.google.com/linux/earth/deb/ stable main` |
| `earth_repo_name`     | Google Earth Repository.                           | `/etc/apt/sources.list.d/google-earth-pro.list` |
| `earth_gpg`           | Google Earth Pub Key.                              | `https://dl.google.com/linux/linux_signing_key.pub` |
| `earth_gpg_key`       | Google Earth GPG Key.                              | `/etc/apt/trusted.gpg.d/google.gpg` |
| `earth_pkg`           | Specify Google Earth package name.                 | `google-earth-pro-stable` |


## Dependencies

No Dependencies

## Playbook

```yaml
- name: Install Google Earth
  hosts: all
  become: true
  vars:

  roles:
    - role: almir-ansible.google-earth
```

## Author Information

-   [Almir Zohorovic](https://github.com/brcak-zmaj)