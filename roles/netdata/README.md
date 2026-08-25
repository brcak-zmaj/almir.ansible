<p align="center">
<a href="https://www.netdata.cloud#gh-light-mode-only">
  <img src="https://www.netdata.cloud/img/readme-images/netdata_readme_logo_light.png" alt="Netdata" width="300"/>
</a>
<a href="https://www.netdata.cloud#gh-dark-mode-only">
  <img src="https://www.netdata.cloud/img/readme-images/netdata_readme_logo_dark.png" alt="Netdata" width="300"/>
</a>
</p>
<h3 align="center">X-Ray Vision for your infrastructure!</h3>

# Ansible Role - Netdata

A comprehensive Ansible role for deploying and configuring Netdata monitoring agent on single node Linux systems with extensive alerting and notification capabilities.

## Overview

Netdata is a real-time performance monitoring tool that provides detailed insights into system metrics. This role automates the installation and configuration of Netdata using the official kickstart script, with full support for customizable alerts and multiple notification channels.

## Features

### Installation
- **Kickstart Script**: Uses official Netdata kickstart script for reliable installation
- **Release Channels**: Support for both stable and nightly releases
- **Version Control**: Pin to specific versions or use latest releases
- **Auto-Updates**: Configurable automatic updates
- **Cloud Integration**: Optional Netdata Cloud connection

### Alerting System
- **General System Alerts**: CPU, memory, disk, load, swap, network latency, dropped packets, inodes, login failures, process count
- **Web Server Alerts**: Nginx and Apache monitoring (connections, request rates, errors, workers)
- **Database Alerts**: MySQL monitoring (slow queries, connections, replication, InnoDB metrics)
- **Container Alerts**: Docker monitoring (daemon resources, disk usage, swarm status)
- **Kubernetes Alerts**: Comprehensive K8s monitoring (pods, nodes, API latency, resource pressure)
- **Storage Alerts**: ZFS monitoring (ARC, pool capacity, fragmentation, disk errors)
- **Hardware Alerts**: SMART disk monitoring

### Notification Channels
- **Email**: SMTP-based email notifications
- **Slack**: Webhook-based Slack notifications
- **Discord**: Webhook-based Discord notifications
- **PagerDuty**: Integration with PagerDuty
- **Telegram**: Bot-based Telegram notifications
- **Microsoft Teams**: Webhook-based Teams notifications
- **Rocket.Chat**: Webhook-based Rocket.Chat notifications
- **Twilio**: SMS notifications via Twilio
- **Pushover**: Mobile push notifications
- **Pushbullet**: Cross-platform push notifications
- **Custom Webhooks**: Generic webhook support

### Configuration Management
- **Variable-Driven**: All configuration controlled via Ansible variables
- **Environment Variable Lookups**: Secure credential management via environment variables (Semaphore-compatible)
- **Idempotent**: Safe to run multiple times
- **Conditional Deployment**: Enable/disable specific alert categories

## Requirements

### Ansible Version Compatibility

This role is tested and supported with:
- **Ansible**: `>= 2.9`
- **Python**: `>= 3.6` (on target system)

### Target System Requirements

- **OS**: Linux (RedHat-based or Debian-based)
- **Access**: SSH access with sudo/root privileges
- **Python**: Python 3 installed on target system
- **Internet**: Access to download Netdata kickstart script (unless using offline installation)

### Dependencies

- **Distribution Packages**: Role installs required dependencies automatically

## Installation

This role is part of the `brcak_zmaj.almir_ansible` collection. Install the collection:

```bash
ansible-galaxy collection install brcak_zmaj.almir_ansible
```

## Role Variables

### Installation Configuration

| Variable Name | Description | Default Value |
|---------------|-------------|---------------|
| `netdata_install_enabled` | Enable Netdata installation | `true` |
| `netdata_kickstart_url` | URL for Netdata kickstart script | `https://get.netdata.cloud/kickstart.sh` |
| `netdata_kickstart_script_path` | Local path for downloaded script | `/tmp/netdata-kickstart.sh` |
| `netdata_web_port` | Netdata web interface port | `19999` |
| `kickstart_no_log` | Hide sensitive kickstart output (e.g., claim tokens) | `false` |

### Dependency Packages

| Variable Name | Description | Default Value |
|---------------|-------------|---------------|
| `netdata_dependencies_redhat` | List of packages for RedHat-based systems | See defaults/main.yml |
| `netdata_dependencies_debian` | List of packages for Debian-based systems | See defaults/main.yml |

You can customize the dependency lists by overriding these variables in your playbook or vars files.

### Kickstart Script Parameters

| Variable Name | Description | Default Value |
|---------------|-------------|---------------|
| `netdata_install_prefix` | Custom install directory (empty = default) | `""` |
| `netdata_old_install_prefix` | Clean previous install directory | `""` |
| `netdata_non_interactive` | No prompts (good for automation) | `true` |
| `netdata_interactive` | Force interactive prompts | `false` |
| `netdata_release_channel` | Release channel: `stable` or `nightly` | `stable` |
| `netdata_install_version` | Install specific version (empty = latest) | `""` |
| `netdata_auto_update` | Enable automatic updates | `true` |
| `netdata_no_updates` | Disable updates | `false` |
| `netdata_claim_token` | Claim token for Netdata Cloud | `""` |
| `netdata_claim_rooms` | Assign node to Cloud Rooms (comma-separated) | `""` |
| `netdata_disable_telemetry` | Disable telemetry | `false` |
| `netdata_reinstall` | Reinstall existing Netdata | `false` |
| `netdata_uninstall` | Uninstall Netdata completely | `false` |

### Notification Configuration

#### Email Notification

| Variable Name | Description | Default Value |
|---------------|-------------|---------------|
| `netdata_email_enabled` | Enable email notifications | `true` |
| `netdata_email_recipient` | Email recipient (env: `NETDATA_EMAIL_RECIPIENT`) | `""` |
| `netdata_email_sender` | Sender email (env: `NETDATA_EMAIL_SENDER`) | `""` |
| `netdata_smtp_server` | SMTP server (env: `NETDATA_SMTP_SERVER`) | `""` |
| `netdata_smtp_port` | SMTP port | `587` |
| `netdata_smtp_user` | SMTP username (env: `NETDATA_SMTP_USER`) | `""` |
| `netdata_smtp_password` | SMTP password (env: `NETDATA_SMTP_PASSWORD`) | `""` |
| `netdata_smtp_ssl` | Use SSL/TLS for SMTP | `true` |
| `netdata_smtp_starttls` | Use STARTTLS | `true` |

#### Slack Notification

| Variable Name | Description | Default Value |
|---------------|-------------|---------------|
| `netdata_slack_enabled` | Enable Slack notifications | `false` |
| `netdata_slack_webhook_url` | Slack webhook URL (env: `NETDATA_SLACK_WEBHOOK_URL`) | `""` |
| `netdata_slack_channel` | Slack channel (env: `NETDATA_SLACK_CHANNEL`) | `#netdata` |
| `netdata_slack_username` | Bot username | `Netdata` |
| `netdata_slack_icon_emoji` | Bot icon emoji | `:chart_with_upwards_trend:` |
| `netdata_slack_send_resolved` | Send clear notifications | `true` |

#### Discord Notification

| Variable Name | Description | Default Value |
|---------------|-------------|---------------|
| `netdata_discord_enabled` | Enable Discord notifications | `false` |
| `netdata_discord_webhook_url` | Discord webhook URL (env: `NETDATA_DISCORD_WEBHOOK_URL`) | `""` |
| `netdata_discord_username` | Bot username | `Netdata` |
| `netdata_discord_avatar_url` | Bot avatar URL | `""` |
| `netdata_discord_send_resolved` | Send clear notifications | `true` |

#### PagerDuty Notification

| Variable Name | Description | Default Value |
|---------------|-------------|---------------|
| `netdata_pagerduty_enabled` | Enable PagerDuty notifications | `false` |
| `netdata_pagerduty_service_key` | PagerDuty service key (env: `NETDATA_PAGERDUTY_SERVICE_KEY`) | `""` |
| `netdata_pagerduty_client_name` | Client name | `Netdata` |
| `netdata_pagerduty_send_resolved` | Send clear notifications | `true` |

#### Telegram Notification

| Variable Name | Description | Default Value |
|---------------|-------------|---------------|
| `netdata_telegram_enabled` | Enable Telegram notifications | `false` |
| `netdata_telegram_bot_token` | Telegram bot token (env: `NETDATA_TELEGRAM_BOT_TOKEN`) | `""` |
| `netdata_telegram_chat_id` | Telegram chat ID (env: `NETDATA_TELEGRAM_CHAT_ID`) | `""` |
| `netdata_telegram_send_resolved` | Send clear notifications | `true` |

#### Microsoft Teams Notification

| Variable Name | Description | Default Value |
|---------------|-------------|---------------|
| `netdata_teams_enabled` | Enable Teams notifications | `false` |
| `netdata_teams_webhook_url` | Teams webhook URL (env: `NETDATA_TEAMS_WEBHOOK_URL`) | `""` |
| `netdata_teams_send_resolved` | Send clear notifications | `true` |

#### Rocket.Chat Notification

| Variable Name | Description | Default Value |
|---------------|-------------|---------------|
| `netdata_rocketchat_enabled` | Enable Rocket.Chat notifications | `false` |
| `netdata_rocketchat_webhook_url` | Rocket.Chat webhook URL (env: `NETDATA_ROCKETCHAT_WEBHOOK_URL`) | `""` |
| `netdata_rocketchat_channel` | Rocket.Chat channel (env: `NETDATA_ROCKETCHAT_CHANNEL`) | `#netdata` |
| `netdata_rocketchat_username` | Bot username | `Netdata` |
| `netdata_rocketchat_icon_emoji` | Bot icon emoji | `:chart_with_upwards_trend:` |
| `netdata_rocketchat_send_resolved` | Send clear notifications | `true` |

#### Twilio Notification

| Variable Name | Description | Default Value |
|---------------|-------------|---------------|
| `netdata_twilio_enabled` | Enable Twilio SMS notifications | `false` |
| `netdata_twilio_account_sid` | Twilio account SID (env: `NETDATA_TWILIO_ACCOUNT_SID`) | `""` |
| `netdata_twilio_auth_token` | Twilio auth token (env: `NETDATA_TWILIO_AUTH_TOKEN`) | `""` |
| `netdata_twilio_from_number` | From phone number (env: `NETDATA_TWILIO_FROM_NUMBER`) | `""` |
| `netdata_twilio_to_number` | To phone number (env: `NETDATA_TWILIO_TO_NUMBER`) | `""` |
| `netdata_twilio_send_resolved` | Send clear notifications | `false` |

#### Pushover Notification

| Variable Name | Description | Default Value |
|---------------|-------------|---------------|
| `netdata_pushover_enabled` | Enable Pushover notifications | `false` |
| `netdata_pushover_user_key` | Pushover user key (env: `NETDATA_PUSHOVER_USER_KEY`) | `""` |
| `netdata_pushover_api_token` | Pushover API token (env: `NETDATA_PUSHOVER_API_TOKEN`) | `""` |
| `netdata_pushover_priority` | Priority: -2 to 2 | `0` |
| `netdata_pushover_sound` | Sound name | `pushover` |
| `netdata_pushover_send_resolved` | Send clear notifications | `true` |

#### Pushbullet Notification

| Variable Name | Description | Default Value |
|---------------|-------------|---------------|
| `netdata_pushbullet_enabled` | Enable Pushbullet notifications | `false` |
| `netdata_pushbullet_api_token` | Pushbullet API token (env: `NETDATA_PUSHBULLET_API_TOKEN`) | `""` |
| `netdata_pushbullet_send_resolved` | Send clear notifications | `true` |

#### Custom Webhook Notification

| Variable Name | Description | Default Value |
|---------------|-------------|---------------|
| `netdata_webhook_enabled` | Enable custom webhook notifications | `false` |
| `netdata_webhook_url` | Webhook URL (env: `NETDATA_WEBHOOK_URL`) | `""` |
| `netdata_webhook_method` | HTTP method | `POST` |
| `netdata_webhook_headers` | Custom headers as dictionary | `{}` |
| `netdata_webhook_timeout` | Timeout in seconds | `10` |

### Custom Alarm Configuration

| Variable Name | Description | Default Value |
|---------------|-------------|---------------|
| `netdata_custom_alarm_files` | List of custom alarm file paths to copy | `[]` |
| `netdata_custom_alarm_dir` | Directory containing custom alarm files (empty = disabled) | `""` |

**Example Usage:**

```yaml
vars:
  # Copy individual custom alarm files
  netdata_custom_alarm_files:
    - "/path/to/my_custom_alarm.conf"
    - "/path/to/another_alarm.conf"
  
  # Or copy all .conf files from a directory
  netdata_custom_alarm_dir: "/path/to/custom_alarms/"
```

Custom alarms are deployed **BEFORE** the default alarms, allowing you to override or extend the default alert configuration.

### Alert Configuration

#### General System Alerts

All general alerts support the following threshold variables:
- `*_warn_threshold`: Warning threshold
- `*_crit_threshold`: Critical threshold
- `*_lookup_period`: Lookup period (e.g., `-15m`)
- `*_every`: Check interval (e.g., `1m`)
- `*_delay`: Delay configuration (e.g., `up 5m down 15m multiplier 1.5 max 1h`)

| Alert Type | Variables |
|------------|-----------|
| CPU | `netdata_cpu_*` |
| Memory | `netdata_memory_*` |
| Disk Usage | `netdata_disk_*` |
| Load Average | `netdata_load_*` |
| Swap Usage | `netdata_swap_*` |
| Network Latency | `netdata_net_latency_*` |
| Dropped Packets | `netdata_dropped_packets_*` |
| Inode Usage | `netdata_inode_*` |
| Login Failures | `netdata_login_failures_*` |
| Many Processes | `netdata_many_processes_*` |
| Recent Reboot | `netdata_recent_reboot_*` |

#### Service-Specific Alerts

Service alerts can be enabled/disabled via:
- `netdata_nginx_alerts_enabled`
- `netdata_apache_alerts_enabled`
- `netdata_mysql_alerts_enabled`
- `netdata_docker_alerts_enabled`
- `netdata_kubernetes_alerts_enabled`
- `netdata_zfs_alerts_enabled`
- `netdata_smartd_alerts_enabled`

Each service has its own set of threshold variables following the pattern:
- `netdata_<service>_<alert_name>_warn`
- `netdata_<service>_<alert_name>_crit`
- `netdata_<service>_<alert_name>_lookup`
- `netdata_<service>_<alert_name>_every`

### Memory Trigger Script

| Variable Name | Description | Default Value |
|---------------|-------------|---------------|
| `netdata_memory_trigger_enabled` | Enable memory trigger script | `false` |
| `netdata_memory_trigger_threshold` | Memory threshold for trigger | `80` |
| `netdata_memory_trigger_services` | List of services to restart | `["netdata"]` |

### File Permissions

| Variable Name | Description | Default Value |
|---------------|-------------|---------------|
| `netdata_config_dir` | Netdata configuration directory | `/etc/netdata` |
| `netdata_health_dir` | Netdata health alerts directory | `/etc/netdata/health.d` |
| `netdata_config_dir_mode` | Config directory permissions | `0755` |
| `netdata_health_dir_mode` | Health directory permissions | `0755` |
| `netdata_config_file_mode` | Config file permissions | `0644` |
| `netdata_script_mode` | Script permissions | `0755` |

### Netdata.conf Configuration

| Variable Name | Description | Default Value |
|---------------|-------------|---------------|
| `netdata_config_file_custom` | Path to custom netdata.conf file (empty = use role template) | `""` |
| `netdata_hostname` | Override hostname in netdata.conf (empty = use system hostname) | `""` |
| `netdata_enable_anonymous_dashboard` | Enable anonymous dashboard access (allows access from any IP) | `true` |

The role provides a template for `netdata.conf` that uses variables from `defaults/main.yml`:
- `netdata_web_port` → `[web] default port`
- `netdata_config_dir` → `[directories] config`
- `netdata_health_dir` → `[directories] health config`
- `netdata_hostname` → `[global] hostname` (if specified)
- `netdata_enable_anonymous_dashboard` → `[web] allow dashboard from` (sets to `*` when enabled)

**Note on Anonymous Dashboard Access:**

In Netdata 2.0+, accessing the root URL (`http://hostname:19999`) shows a landing page. To access the dashboard directly without the landing page:
- Use the `/v3` endpoint: `http://hostname:19999/v3`
- The role's debug message will show both URLs when `netdata_enable_anonymous_dashboard` is enabled
- You can bookmark `/v3` for direct dashboard access

If you prefer to use your own `netdata.conf` file, set `netdata_config_file_custom` to the path of your file. The role will copy it instead of using the template.

### Email Configuration
- `NETDATA_EMAIL_RECIPIENT`
- `NETDATA_EMAIL_SENDER`
- `NETDATA_SMTP_SERVER`
- `NETDATA_SMTP_PORT`
- `NETDATA_SMTP_USER`
- `NETDATA_SMTP_PASSWORD`

### Slack Configuration
- `NETDATA_SLACK_WEBHOOK_URL`
- `NETDATA_SLACK_CHANNEL`

### Discord Configuration
- `NETDATA_DISCORD_WEBHOOK_URL`

### PagerDuty Configuration
- `NETDATA_PAGERDUTY_SERVICE_KEY`

### Telegram Configuration
- `NETDATA_TELEGRAM_BOT_TOKEN`
- `NETDATA_TELEGRAM_CHAT_ID`

### Teams Configuration
- `NETDATA_TEAMS_WEBHOOK_URL`

### Rocket.Chat Configuration
- `NETDATA_ROCKETCHAT_WEBHOOK_URL`
- `NETDATA_ROCKETCHAT_CHANNEL`

### Twilio Configuration
- `NETDATA_TWILIO_ACCOUNT_SID`
- `NETDATA_TWILIO_AUTH_TOKEN`
- `NETDATA_TWILIO_FROM_NUMBER`
- `NETDATA_TWILIO_TO_NUMBER`

### Pushover Configuration
- `NETDATA_PUSHOVER_USER_KEY`
- `NETDATA_PUSHOVER_API_TOKEN`

### Pushbullet Configuration
- `NETDATA_PUSHBULLET_API_TOKEN`

### Webhook Configuration
- `NETDATA_WEBHOOK_URL`

### Netdata Cloud Configuration
- `NETDATA_CLAIM_TOKEN`

## Tags

The role supports the following tags for selective execution:

- `netdata`: Execute all Netdata-related tasks
- `common`: Execute common tasks (dependencies, etc.)

## Dependencies

None. This role is self-contained and installs all required dependencies.

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
