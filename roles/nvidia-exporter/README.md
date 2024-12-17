<img src="https://raw.githubusercontent.com/geerlingguy/mac-dev-playbook/master/files/Mac-Dev-Playbook-Logo.png" width="250" height="156" alt="Playbook Logo" /> <img src="https://upload.wikimedia.org/wikipedia/sco/thumb/2/21/Nvidia_logo.svg/351px-Nvidia_logo.svg.png" width="250" height="156" alt="Nvidia Logo" />

## Ansible role - nvidia-exporter

This ansible role will setup the nvidia exporter agent on a target that has an nvidia GPU. This is used to enable metrics for displaying into Grafana. Inspiration and code was used from this repository https://github.com/utkuozdemir/nvidia_gpu_exporter

## Requirements

- Ansible 2.13+

## Role Variables

| Variable Name         | Description                                                          | Default Value                                                       |
|-----------------------|----------------------------------------------------------------------|---------------------------------------------------------------------|
| `gpu_exporter_url`              | nvidia exporter version.                                         | `https://github.com/utkuozdemir/nvidia_gpu_exporter/archive/refs/tags/v1.2.1.tar.gz` |
| `nvidia_gpu_exporter_user`      | This is where you set the user you want running this exporter.   | `nvidia_gpu_exporter` |
| `nvidia_gpu_exporter_group`     | This is where you set the group you want running this exporter.  | `nvidia_gpu_exporter` |
| `nvidia_exporter_service_name`  | This is where you set the service name.                          | `nvidia_gpu_exporter` |
| `gpu_exporter_binary`           | Location of the binary.                                          | `/usr/bin/{{ nvidia_exporter_service_name }}` |
| `gpu_exporter_service`          | Location of the serivice.                                        | `/etc/systemd/system/{{ nvidia_exporter_service_name }}.service` |
 

## Dependencies

No Dependencies

## Official Grafana Dashboard
[Grafana dashboard](https://grafana.com/grafana/dashboards/14574)

## Example of how your dashboard can look like
![Grafana dashboard](https://raw.githubusercontent.com/utkuozdemir/nvidia_gpu_exporter/master/grafana/dashboard.png)

## Metrics
See https://github.com/utkuozdemir/nvidia_gpu_exporter/blob/master/METRICS.md 

## Playbook

```yaml
- name: Install utkuozdemir/nvidia_gpu_exporter
  hosts: transcoder_server
  become: true
  vars:

  roles:
    - role: almir.ansible.nvidia-exporter
```

## Author Information

-   [Almir Zohorovic](https://github.com/brcak-zmaj)
-   [Utku Ozdemir] (https://github.com/utkuozdemir)