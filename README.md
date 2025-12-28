<img src="https://raw.githubusercontent.com/geerlingguy/mac-dev-playbook/master/files/Mac-Dev-Playbook-Logo.png" width="250" height="156" alt="Playbook Logo" />

# Ansible Collection for Brcak Zmaj - Almir 

[![Ansible Collection](https://img.shields.io/badge/brcak.zmaj-brightgreen)](https://galaxy.ansible.com/ui/repo/published/brcak-zmaj/almir_ansible)
[![GitHub tag](https://img.shields.io/github/tag/brcak-zmaj/brcak-zmaj-ansible-collection.svg)](https://github.com/brcak-zmaj/almir.ansible/tags)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/brcak-zmaj/almir.ansible)](https://github.com/brcak-zmaj/almir.ansible/tags)
[![GitHub Contributors](https://img.shields.io/github/contributors/brcak-zmaj/almir.ansible)](https://github.com/brcak-zmaj/almir.ansible/tags)


## Ansible version compatibility

The collection is tested and supported with: `ansible >= 2.9`

## Installing the collection

Before using the Grafana collection, you need to install it using the below command:

```shell
ansible-galaxy collection install brcak-zmaj.almir_ansible
```

## Roles included in the collection

This collection includes the following roles to help set up and manage Brave Browser, debloating, My Dev workstation, proxmox:

- **brave-browser**: Installs and configures Brave Web Browser on your target hosts.
- **debloat**: Cleans up and unneeded packages including language packs.
- **my-pc-setup**: This is intended to configure and setup my development machine. Installs all packages I need, sets up mountpoints and configures the appearance.
- **proxmox-restore_snapshot**: Developed to make it easy to include into playbooks for restoring snapshots when nessesary.
- **proxmox-tuning**: Configures a vanilla proxmox server to a production and tuned server
- **docker-tuning**: Configures various sysctl parameters to bulletproof a server that's running docker containers
- **mysql-tuning**: Configures various sysctl parameters to bulletproof a server that's running MySQL
- **postgresql-tuning**: Configures various sysctl parameters to bulletproof a server that's running PostgreSQL

## Contributing

I am accepting GitHub pull requests and issues. There are many ways in which you can participate in the codebase, for example:

-   Submit bugs and feature requests, and help me verify them
-   Submit and review source code changes in GitHub pull requests
-   Add new roles, modules, etc for more brcak-zmaj resources

## License

GPL-3.0-or-later

> Note: I am providing code in the repository to you under an open source license. Because this is my personal repository, the license you receive to my code is from me and not my employer.
