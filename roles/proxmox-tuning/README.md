<img src="https://raw.githubusercontent.com/geerlingguy/mac-dev-playbook/master/files/Mac-Dev-Playbook-Logo.png" width="250" height="156" alt="Playbook Logo" />
<img src="https://img.icons8.com/?size=100&id=GxnnEGl75yew&format=png&color=000000" width="250" height="156" alt="Proxmox Logo" />

## Ansible role - Proxmox Tuning

This ansible role will configure and tune your proxmox instance and make it ready for production

## Requirements

- Ansible 2.13+

## Role Defaults

| Variable Name         | Description                                                          | Default Value                                                       |
|-----------------------|----------------------------------------------------------------------|---------------------------------------------------------------------|
| `vzdump_tmpdir`       | Overriding default tmpdir path                                       | `/mnt/backups` |
| `vzdump_dumpdir`      | Enable dumpdir and set its path                                      | `/mnt/backups/dumps` |
| `vzdump_storage`      | Enable storage configuration                                         | `local-backup` |
| `vzdump_mode`         | Enable backup mode                                                   | `snapshot` |
| `vzdump_bwlimit`      | Set bandwidth limit (in KB)                                          | `4096` |
| `vzdump_ionice`       | Set ionice class value                                               | `2` |
| `vzdump_lockwait`     | Enable lockwait (in minutes)                                         | `5` |
| `vzdump_stopwait`     | Enable stopwait (in minutes)                                         | `10` |
| `vzdump_stdexcludes`  | Enable stdexcludes (exclude system directories)                      | `true` |
| `vzdump_mailto`       | Enable mail notifications                                            | `admin@example.com` |
| `vzdump_prune_backups` | Enable prune backups                                                | `keep-daily=7,keep-weekly=4,keep-monthly=12` |
| `vzdump_script`       | Specify pre/post backup script                                       | `/home/user/temp` |
| `vzdump_exclude_path` | Specify directories to exclude                                       | `` |
| `pve_repo_type`       |                                                                      | `no-subscription` |
| `cpu_governor_pkg`    | Install specific CPU Governor Package                                | `linux-cpupower` |
| `pve_set_cpu`         |                                                                      | `no` |
| `pve_cpu_governor`    |                                                                      | `performance` |
| `ksm_ps_metric`       |                                                                      | `pss` |
| `ksm_logfile_path`    |                                                                      | `/var/log/ksmtuned` |
| `ksm_debug`           | Enable or disable debug                                              | `1` |
| `ksmtuned_pkg`        | Install KSM Package                                                  | `ksmtuned` |
| `ksmtuned_conf`       | KSM Conf File Location                                               | `/etc/ksmtuned.conf` |
| `ksm_monitor_interval`  |  For tuning intervals                                              | `60` |
| `ksm_sleep_msec`      | Faster memory sharing scan (smaller servers sleep more)              | `20` |
| `ksm_npages_boost`    | Boost factor for KSM page sharing                                    | `300` |
| `ksm_npages_decay`    | Decay factor for KSM pages                                           | `-50` |
| `ksm_npages_min`      | Minimum number of pages for KSM sharing                              | `64` |
| `ksm_npages_max`      | Maximum number of pages for KSM sharing                              | `1250` |
| `ksm_threshold_coef`  | Moderate KSM aggressiveness for 128GB memory                         | `20` |
| `ksm_threshold_const` | Threshold constant for memory sharing                                | `2048` |
| `common_packages`     | Sets up nessesary packages                                           | `module-assistant, aria2, apt-transport-https,...` |
| `additional_packages:` | Variable for additional Packages                                    | `wget,...` |


## Dependencies

No Dependencies

## Playbook

```yaml
- name: Setup Proxmox
  hosts: proxmox
  become: true
  vars:

  roles:
    - role: almir.ansible.proxmox-tuning
```

## Author Information

-   [Almir Zohorovic](https://github.com/brcak-zmaj)

