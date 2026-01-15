<img src="https://kiwix.org/wp-content/uploads/2023/08/Kiwix-horizontal-logo-1.svg" width="250" height="156" alt="Playbook Logo" />

# Ansible Role - Kiwix ZIM File Management & Server

A comprehensive Ansible role for managing Kiwix ZIM file downloads and deploying Kiwix server with multiple installation methods (package manager, Docker, or Flatpak).

## Features

This role deploys Kiwix server (package, Docker, or Flatpak) and places helper scripts and configuration where the user can manage ZIM files locally.

- Script deployment: copies `kiwix_zim_fetcher.sh` and `kiwix_zim_sync.sh` into the configured `kiwix_install_path` (defaults to `{{ kiwix_home }}/kiwix`).
- Desktop configuration: optionally deploys a `kiwix-desktop` config that points the desktop app at the `zim_files` directory.
- Installation methods: install via package manager, Docker, or Flatpak (controlled by `kiwix_install_method`).
- Optional cron: install a cron job to run `kiwix_zim_sync.sh` automatically (controlled by `kiwix_enable_cron`).

Important: The role no longer performs ZIM downloads. ZIM file discovery and downloading are handled by the included scripts (`kiwix_zim_fetcher.sh`, `kiwix_zim_sync.sh`). The role will copy any user-provided `zim_urls.txt` into the target `zim_files/` directory if you set `kiwix_local_urls_file`.

## Requirements

### Ansible Version Compatibility

This role is tested and supported with:
- **Ansible**: `>= 2.9`
- **Python**: `>= 3.6` (on target system)

### Target System Requirements

- **OS**: Linux (Debian, Ubuntu, RedHat, CentOS, Fedora, Arch Linux)
- **Access**: SSH access with sudo/root privileges
- **Python**: Python 3 installed on target system

### Dependencies

- **For Docker**: Docker or a Docker role (recommended)
- **For Flatpak**: Flatpak must be installed if using Flatpak

## Standalone Scripts

### kiwix_zim_fetcher.sh

Generates a list of ZIM file URLs from https://download.kiwix.org/zim/

**Location**: `files/kiwix_zim_fetcher.sh`

**Usage:**
```bash
cd /path/to/kiwix/files
./kiwix_zim_fetcher.sh
```

**Features:**
- Interactive menu for configuration
- Language filtering (any language code)
- Scope selection (folder-by-folder, everything, language-only, custom)
- File type filtering (all, nopic, maxi, latest)
- Date and size filtering
- Generates URL list file (default: `files/zim_files/zim_urls.txt`)

### Downloading ZIM files

This role does not perform ZIM downloads. Use the included helper scripts (`kiwix_zim_fetcher.sh`, `kiwix_zim_sync.sh`) or your preferred download tooling to fetch ZIM files.

- To generate a URL list: run `kiwix_zim_fetcher.sh` (interactive) in the `files/` directory.
- To sync/download using the script on a host: run `kiwix_zim_sync.sh` with the generated `zim_urls.txt` and a target directory (for example on a NAS or the target host).
- If you have a prepared `zim_urls.txt` on the Ansible controller, set `kiwix_local_urls_file` to have the role copy it into `{{ kiwix_install_path }}/zim_files/zim_urls.txt` on the target.

## Example Playbooks

### Basic Package Installation

```yaml
---
- name: Install Kiwix
  hosts: kiwix_server
  become: true
  roles:
    - role: brcak_zmaj.almir_ansible.kiwix
  vars:
    kiwix_install_method: package
    kiwix_install_path: /opt/kiwix
    kiwix_local_urls_file: /path/on/controller/zim_urls.txt
```

### Docker Installation

```yaml
---
- name: Install Kiwix via Docker
  hosts: kiwix_server
  become: true
  roles:
    - role: geerlingguy.docker  # Install Docker first
    - role: brcak_zmaj.almir_ansible.kiwix
  vars:
    kiwix_install_method: docker
    kiwix_docker_port: 8080
    kiwix_docker_memory: "4g"
    kiwix_docker_cpus: 4
    kiwix_install_path: /opt/kiwix
    kiwix_local_urls_file: /path/on/controller/zim_urls.txt
```

### Sync Pre-downloaded Files

```yaml
---
- name: Sync ZIM files and install Kiwix
  hosts: kiwix_server
  become: true
  roles:
    - role: brcak_zmaj.almir_ansible.kiwix
  vars:
    kiwix_install_method: package
    kiwix_install_path: /opt/kiwix
    kiwix_zim_source_custom: /mnt/nas/kiwix/files
```

### Custom Configuration

```yaml
---
- name: Custom Kiwix setup
  hosts: kiwix_server
  become: true
  roles:
    - role: brcak_zmaj.almir_ansible.kiwix
  vars:
    kiwix_install_method: docker
    kiwix_install_path: /mnt/storage/kiwix
    kiwix_docker_port: 9090
    kiwix_docker_memory: "8g"
    kiwix_docker_cpus: 4
    kiwix_enable_cron: true
    kiwix_cron_schedule: "0 2 * * *"
```

## Workflow

### Step 1: Generate URL List

```bash
cd /path/to/kiwix/files
./kiwix_zim_fetcher.sh
```

Follow the interactive prompts to:
1. Select language (e.g., `en`, `de`, `fr`, or `all`)
2. Choose scope (folder-by-folder, everything, language-only, custom)
3. Set filters (date, size, type)
4. Specify output locations
5. Choose to generate list only or generate and download

### Step 2: Download Files

Use the `kiwix_zim_sync.sh` script on your target host or NAS:

```bash
# On the host where you want to download ZIM files:
cd /path/to/zim_files_directory
/path/to/kiwix_zim_sync.sh sync -a \
  -p /path/to/zim_files \
  -u /path/to/zim_urls.txt
```

Or enable automated syncing via cron (set `kiwix_enable_cron: true` in playbook vars).

### Step 3: Install Kiwix Server

Run the Ansible playbook with your chosen installation method.

## Advanced Configuration

### Cron-based Automated Syncing

Enable automatic ZIM file updates via cron:

```yaml
kiwix_enable_cron: true
kiwix_cron_schedule: "0 3 * * 0"  # Weekly Sunday at 3 AM
kiwix_cron_cmd: >
  {{ kiwix_install_path }}/kiwix_zim_sync.sh sync -a
  -p {{ kiwix_install_path }}/zim_files
  -u {{ kiwix_install_path }}/zim_files/zim_urls.txt
  >> /var/log/kiwix.log 2>&1
```

### Desktop Configuration

Enable automatic kiwix-desktop configuration (package installations only):

```yaml
kiwix_deploy_config: true  # Deploys config pointing to zim_files directory
```

## Troubleshooting

### Docker Network Issues

If Docker network creation fails:
1. Ensure Docker is installed and running
2. Check if network already exists: `docker network ls`
3. Set `kiwix_docker_network_create: false` to use existing network

### Flatpak Installation Fails

Ensure Flatpak is installed and functional on the target system.

### Script Permission Issues

If scripts don't execute, verify they have execute permissions:
```bash
chmod +x {{ kiwix_install_path }}/kiwix_zim_sync.sh
chmod +x {{ kiwix_install_path }}/kiwix_zim_fetcher.sh
```

## Notes

- **Script-driven Downloads**: The role deploys scripts; users are responsible for running downloads
- **Flexible Installation Paths**: All files are copied to `kiwix_install_path` for easy relocation
- **Idempotent**: Role and scripts are idempotent - rerunning is safe
- **Docker Mounts**: Docker container automatically mounts `kiwix_install_path` to `/data` in the container
- **Docker Dependencies**: Docker installation requires `geerlingguy.docker` role or manual Docker setup
- **Flatpak Support**: Flatpak installations work with locally stored ZIM files

## Configuration Variables Reference

Key variables (see `defaults/main.yml` for complete list):

- `kiwix_user`: Linux user to own the installation (default: `almir`)
- `kiwix_home`: User's home directory
- `kiwix_install_path`: Base path for scripts and ZIM files (default: `{{ kiwix_home }}/kiwix`)
- `kiwix_install_method`: `package`, `docker`, or `flatpak`
- `kiwix_local_urls_file`: Optional path to a pre-generated `zim_urls.txt` on the controller to copy to target
- `kiwix_zim_source_custom`: Path on target to an existing ZIM files directory to sync into the role's path
- `kiwix_enable_cron`: Enable automated cron-based syncing (default: `false`)
- `kiwix_deploy_config`: Deploy kiwix-desktop config file (default: `true`)
- `kiwix_uninstall`: Set to `true` to uninstall Kiwix

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
