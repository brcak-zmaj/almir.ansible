<img src="https://raw.githubusercontent.com/geerlingguy/mac-dev-playbook/master/files/Mac-Dev-Playbook-Logo.png" width="250" height="156" alt="Playbook Logo" />


# Ansible Role - Docker Server Tuning

This Ansible role applies optimized system settings for servers running Docker, ensuring maximum performance, reliability, and efficiency.

## Requirements

- Ansible 2.13+
- Compatible with Debian-based and RHEL-based distributions.

## Role Variables

| Variable Name                           | Description                                                     | Default Value |
|-----------------------------------------|-----------------------------------------------------------------|--------------|
| `sysctl_fs_file_max`                    | Maximum number of open files system-wide.                       | `2097152` |
| `sysctl_fs_nr_open`                     | Maximum number of file descriptors that a process can allocate. | `2097152` |
| `sysctl_net_core_netdev_max_backlog`     | Maximum number of packets queued on the input side when system is under heavy load. | `16384` |
| `sysctl_net_ipv4_tcp_rmem`              | TCP read buffer sizes.                                          | `"4096 87380 16777216"` |
| `sysctl_net_ipv4_tcp_wmem`              | TCP write buffer sizes.                                         | `"4096 65536 16777216"` |
| `sysctl_kernel_shmmax`                  | Maximum shared memory segment size.                            | `68719476736` |
| `sysctl_kernel_shmall`                  | Maximum shared memory pages.                                   | `4294967296` |
| `sysctl_net_ipv4_tcp_max_syn_backlog`   | Maximum number of remembered connection requests.              | `3240000` |
| `sysctl_net_core_somaxconn`             | Maximum number of connections that can be queued for acceptance. | `32768` |
| `sysctl_kernel_pid_max`                 | Maximum number of process IDs available.                       | `4194304` |
| `sysctl_vm_swappiness`                  | Controls swap behavior (lower is better for performance).       | `1` |
| `sysctl_net_ipv4_ip_local_port_range`   | Range of local ports available for outgoing connections.        | `"1024 65535"` |
| `sysctl_fs_inotify_max_user_watches`    | Maximum number of inotify watches per user.                    | `1048576` |
| `sysctl_kernel_sem`                     | Kernel semaphore settings.                                     | `"250 32000 100 128"` |
| `sysctl_net_core_rmem_max` *(RHEL only)* | Maximum receive buffer size.                                   | `16777216` |
| `sysctl_net_core_wmem_max` *(RHEL only)* | Maximum send buffer size.                                      | `16777216` |
| `sysctl_fs_inotify_max_user_instances` *(Debian only)* | Maximum number of inotify instances per user.                 | `8192` |

## Tasks Included

- Apply **sysctl kernel tuning** for optimized performance.
- Configure **network and TCP stack** for higher connection limits.
- Adjust **process limits and inotify settings** for high-performance workloads.
- Install **required RHEL packages** (if applicable).

## Dependencies

No external dependencies.

## Installation

This role is part of the `brcak_zmaj.almir_ansible` collection. Install the collection:

```bash
ansible-galaxy collection install brcak_zmaj.almir_ansible
```

## Example Playbook

```yaml
- name: Apply Docker Server Tuning
  hosts: all
  become: true
  roles:
    - role: brcak_zmaj.almir_ansible.docker_tuning
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
