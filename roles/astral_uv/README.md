# Ansible Role: astral_uv

Install [Astral uv](https://github.com/astral-sh/uv) - an extremely fast Python package and project manager written in Rust.

## Features

- Automatic platform detection (Linux glibc/musl, macOS)
- Version pinning or automatic latest version detection
- Checksum verification
- Optional PATH configuration in shell profiles
- Idempotent installation (skips if already at target version)

## Requirements

- Ansible 2.12+
- Target: Linux (glibc or musl) or macOS
- Internet access to download from GitHub releases

## Role Variables

### Required Variables

None. All variables have sensible defaults.

### Optional Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `uv_version` | `"latest"` | Version to install. Use `"latest"` for auto-detection or pin a specific version like `"0.9.21"` |
| `uv_install_dir` | `~/.local/bin` | Directory where uv binaries are installed |
| `uv_modify_path` | `true` | Whether to add install directory to PATH in shell profiles |
| `uv_shell_profiles` | `["~/.bashrc"]` | Shell profile files to modify when `uv_modify_path` is true |
| `uv_owner` | Current user | Owner of installed binaries |
| `uv_group` | Current group | Group of installed binaries |
| `uv_bin_mode` | `"0755"` | File permissions for binaries |
| `uv_github_base_url` | `"https://github.com"` | Base URL for downloads (useful for GitHub Enterprise) |
| `uv_download_timeout` | `300` | Download timeout in seconds |
| `uv_force_reinstall` | `false` | Force reinstall even if already at target version |
| `uv_verify_checksum` | `true` | Verify SHA256 checksum after download |
| `uv_tmp_dir` | `"/tmp"` | Temporary directory for downloads |
| `uv_cleanup_archive` | `true` | Remove downloaded archive after installation |
| `uv_libc_variant` | `""` | Override libc detection: `"gnu"` or `"musl"` (Linux only) |

## Supported Platforms

### Linux
- x86_64 (glibc, musl)
- aarch64/arm64 (glibc, musl)
- armv7 (glibc, musl)
- i686 (glibc, musl)
- ppc64le, ppc64, s390x, riscv64 (glibc only)

### macOS
- x86_64 (Intel)
- arm64 (Apple Silicon)

## Dependencies

None.

## Example Playbook

### Basic Installation (latest version)

```yaml
- hosts: workstations
  roles:
    - role: astral_uv
```

### Pin Specific Version

```yaml
- hosts: workstations
  roles:
    - role: astral_uv
      uv_version: "0.9.21"
```

### Custom Install Directory

```yaml
- hosts: workstations
  roles:
    - role: astral_uv
      uv_install_dir: "/opt/uv/bin"
      uv_modify_path: false
```

### Multiple Shell Profiles

```yaml
- hosts: workstations
  roles:
    - role: astral_uv
      uv_shell_profiles:
        - "{{ ansible_facts['user_dir'] }}/.bashrc"
        - "{{ ansible_facts['user_dir'] }}/.zshrc"
```

### Force musl Build on Linux

```yaml
- hosts: alpine_servers
  roles:
    - role: astral_uv
      uv_libc_variant: "musl"
```

## What Gets Installed

- `uv` - The main uv binary
- `uvx` - Tool runner (like `pipx run`)

## Notes

- The role automatically detects glibc vs musl on Linux systems
- If glibc version is too old, it falls back to musl builds
- macOS installation works on both Intel and Apple Silicon

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
