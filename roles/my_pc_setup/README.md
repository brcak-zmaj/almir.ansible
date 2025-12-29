<img src="https://raw.githubusercontent.com/geerlingguy/mac-dev-playbook/master/files/Mac-Dev-Playbook-Logo.png" width="250" height="156" alt="Playbook Logo" />



## Ansible role - My PC Setup

This ansible role will is intended to setup my development workstation

## Requirements

- Ansible 2.13+

## Role Defaults

| Variable Name         | Description                                                          | Default Value                                                       |
|-----------------------|----------------------------------------------------------------------|---------------------------------------------------------------------|
| `remmina_pkgs`        | Contains packages I typically use for remmina. | `remmina, remmina-plugin-x2go, remmina-plugin-spice,...` |
| `flatpak_packages`    | Contains flatpaks I use.                       | `com.github.qarmin.czkawka, org.fedoraproject.MediaWriter, fr.romainvigier.MetadataCleaner,...` |
| `flatpak_repo`        | Flatpak Repo.                                  | `https://flathub.org/repo/flathub.flatpakrepo` |
| `java_version`        | Specifies what java version I need.            | `java-11-openjdk` |
| `earth_repo`          | Google earth repo.                             | `deb [signed-by=/etc/apt/trusted.gpg.d/google.gpg arch=amd64] http://dl.google.com/linux/earth/deb/ stable main` |
| `earth_repo_name`     | Location for local repo.                       | `/etc/apt/sources.list.d/google-earth-pro.list` |
| `earth_gpg`           | Google earth signing Key.                      | `https://dl.google.com/linux/linux_signing_key.pub` |
| `earth_gpg_key`       | Google Earth GPG location                      | `/etc/apt/trusted.gpg.d/google.gpg` |
| `earth_pkg`           | Name of the Google Earth Package.              | `google-earth-pro-stable` |
| `virtual_box_key_url` | vbox Key.                                      | `https://www.virtualbox.org/download/oracle_vbox_2016.asc` |
| `virtual_box_repo`    | vbox repo                                      | `deb https://download.virtualbox.org/virtualbox/debian buster contrib` |
| `virtualbox_packages` | vbox packages                                  | `virtualbox, virtualbox-dkms,...` |
| `libreoffice_languages_to_remove` | Remove any unneeded languages      | `libreoffice-help-zh-tw, libreoffice-help-zh-cn, libreoffice-help-ru,...` |
| `libvirt_package`     | Libvirt package name                           | `libvirtd` |
| `virtualization_packages` | Libvirt dependencies                       | `bridge-utils, libvirt, virt-install,...` |
| `smb_mountpoint`      | This is where you enter your SMB Share         | `network.share.example` |
| `mount_point_directories` | Enter all of your mountpoints from the SMB Share  | `- /mnt/example` |
| `smb_mounts`          | Loop multple mountpoints from smb share to mapped dir   | `src: "//{{ smb_mountpoint }}/example", path: "/mnt/example"` |
| `smb_credentials`     | Input SMB Credentials                          | `username={{ smb_username }},password={{ smb_password }}` |
| `smb_mount_opts`      | Cifs Opts                                      | `noperm,dir_mode=0777,file_mode=0777,iocharset=utf8,_netdev,{{ smb_credentials }}` |
| `smb_fstype`          | SMB File System Type                           | `cifs` |
| `gstreamer_debian_packages` | Debian gstreamer dependencies            | `gstreamer1.0-plugins-base, gstreamer1.0-plugins-good, gstreamer1.0-plugins-bad,...` |
| `gstreamer_redhat_packages` | RHEL gstreamer dependencies              | `gstreamer1-plugins-base, gstreamer1-plugins-good, gstreamer1-plugins-bad-free,...` |
| `gnome_shell_extensions_packages` |  Gnome dash to dock and extensions | `gnome-shell-extension-dash-to-dock, gnome-shell-extensions,...` |
| `gnome_shell_enable_extension_command` |  Command to enable gnome dash to dock   | `gnome-extensions enable dash-to-dock@micxgx.gmail.com` |
| `npm_global`          |  NPM Global                                    | `true` |
| `nodejs_npm_packages` | NPM and Dependencies                           | `nodejs, npm,...` |
| `global_npm_packages` | NPM Packages                                   | `"@gridsome/cli", "@semantic-release/changelog", "@semantic-release/git",...` |
| `php_dev_packages`    | Install PHP Packages                           | `php-cli, php-curl, php-intl,...` |
| `python_packages`     | Setup python and pip                           | `python3, python3-pip,...` |
| `pip_packages`        | Install any pip packages                       | `requests, bandit, flake8,...` |
| `rust_packages`       | Install any rust packages                      | `rust, cargo,...` |


## Role Switches - Used to enable or disable a play from kicking off

| Variable Name         | Description                                                          | Examples                                                            |
|-----------------------|----------------------------------------------------------------------|---------------------------------------------------------------------|
| `Development Packages`       | Enables tasks to set up specific packages needed for dev      | `boto, java, linode-cli,...` | 
| `Gaming Packages`            | Enabled anything "Gaming" related                             | `steam,...` | 
| `Multimedia`       | Enabled any packages related to "Multimedia"                            | `codes,...` | 


## Dependencies - These are "optional" but I run them with this role..

- almir.brave-browser
- almir.debloat
- almir.google-chrome
- almir.sublime
- geerlingguy.ansible
- ecgalaxy.vscode


## Installation

This role is part of the `brcak_zmaj.almir_ansible` collection. Install the collection:

```bash
ansible-galaxy collection install brcak_zmaj.almir_ansible
```
## Playbook

```yaml
- name: Setup Dev Workstation
  hosts: Almir Dev Workstation
  become: true
  vars:

  roles:
    - role: brcak_zmaj.almir_ansible.my-pc-setup
```

## Author Information

-   [Almir Zohorovic](https://github.com/brcak-zmaj)


## Stats

![Alt](https://repobeats.axiom.co/api/embed/7a7fe37d43ef2cab7bdbc23ba8c5cfe3cfbdf832.svg "Repobeats analytics image")
