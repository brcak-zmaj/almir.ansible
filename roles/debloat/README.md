## Ansible role - Debloat

This ansible role will remove bloat (unneeded) packages that come preinstalled on a workstation/server

## Requirements

- Ansible 2.13+

## Role Variables

| Variable Name         | Description                                                          | Default Value                                                       |
|-----------------------|----------------------------------------------------------------------|---------------------------------------------------------------------|
| `language_packs`      | Contains any language pack you dont need. | `language-pack-gnome-ar*,language-pack-gnome-de*,language-pack-gnome-es*,...` |
| `redhat_debloat`      | Contains packages you dont need for RHEL. | `cheese-common*,ristretto*,simple-scan*,...` |
| `debian_debloat`      | Contains packages you dont need for DEBIAN.    | `gnome-boxes, gnome-weather, sgt-puzzles,...` |
| `common_debloat`      | Contains common packages you dont need.    | `transmission, ristretto, thunderbird,...` |


## Dependencies

No Dependencies

## Playbook

```yaml
- name: Debloat Targets
  hosts: all
  become: true
  vars:

  roles:
    - role: almir.ansible.debloat
```

## Author Information

-   [Almir Zohorovic](https://github.com/brcak-zmaj)