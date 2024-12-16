## Ansible role - Proxmox Restore Snapshot

This ansible role will is intended to speed up testing, and give you quick way to include a way to restore a snapshot

## Requirements

- Ansible 2.13+

## Role Defaults

| Variable Name         | Description                                                          | Default Value                                                       |
|-----------------------|----------------------------------------------------------------------|---------------------------------------------------------------------|
| `backup_path`         | Location of where the snapshots are            | `/mnt/pve/Local-Backups/dump` |
| `vms`                 | Add you VM's here for the tasks                | `146:, snapshot_name: "vzdump-qemu-146.vma.zst", cpus: 8,  memory: 8192` |
| `cleanup_unused_disks`  | Specify if you want to do cleanup of unused disk  | `true` |


## Dependencies

No Dependencies

## Playbook

```yaml
- name: Restore VM from Snapshot
  hosts: proxmox
  become: true
  vars:

  roles:
    - role: almir.ansible.proxmox-restore_snapshot
```

## Author Information

-   [Almir Zohorovic](https://github.com/brcak-zmaj)

