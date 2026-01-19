# Ansible Role: astral_uv

Install [Astral uv](https://github.com/astral-sh/uv) - an extremely fast Python package and project manager written in Rust.

## Features

- Uses the official standalone installer from [astral.sh](https://docs.astral.sh/uv/getting-started/installation/)
- Automatic platform detection (Linux, macOS)
- Version pinning or automatic latest version
- Idempotent installation (skips if already installed)

## Requirements

- Ansible 2.12+
- Target: Linux or macOS
- `curl` (installed automatically if missing)
- Internet access to download from astral.sh

## Role Variables

### Required Variables

None. All variables have sensible defaults.

### Optional Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `uv_version` | `"latest"` | Version to install. Use `"latest"` for auto-detection or pin a specific version like `"0.9.21"` |
| `uv_install_dir` | `~/.local/bin` | Directory where uv binaries are installed |
| `uv_modify_path` | `true` | Whether the installer should modify shell PATH |
| `uv_force_reinstall` | `false` | Force reinstall even if already installed |

## Supported Platforms

- **Linux**: x86_64, aarch64/arm64, armv7, and more
- **macOS**: Intel (x86_64) and Apple Silicon (arm64)

## Dependencies

None.

## Example Playbook

### Basic Installation (latest version)

```yaml
- hosts: workstations
  roles:
    - role: brcak_zmaj.almir_ansible.astral_uv
```

### Pin Specific Version

```yaml
- hosts: workstations
  roles:
    - role: brcak_zmaj.almir_ansible.astral_uv
      vars:
        uv_version: "0.9.21"
```

### System-wide Installation

```yaml
- hosts: servers
  become: true
  roles:
    - role: brcak_zmaj.almir_ansible.astral_uv
      vars:
        uv_install_dir: /usr/local/bin
        uv_modify_path: false
```

## What Gets Installed

- `uv` - The main uv binary
- `uvx` - Tool runner (like `pipx run`)

## Notes

- The role uses the [official Astral installer](https://docs.astral.sh/uv/getting-started/installation/#standalone-installer)
- The installer automatically detects your platform and downloads the appropriate binary
- For system-wide installation, set `uv_install_dir: /usr/local/bin` and run with `become: true`

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
