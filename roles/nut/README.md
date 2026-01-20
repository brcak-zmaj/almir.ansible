# Ansible Role - NUT (Network UPS Tools)

Install and configure NUT for UPS monitoring and automated shutdown on power failure.

## Overview

NUT (Network UPS Tools) provides a reliable solution for monitoring UPS (Uninterruptible Power Supply) hardware and performing safe system shutdown when battery power is low. This role supports:

- USB-connected UPS devices (most common)
- Network/SNMP-connected UPS devices
- Standalone and networked (server/client) configurations
- Multi-UPS setups

## Requirements

### Ansible Version

- Ansible >= 2.9

### Target System

- Linux (RHEL/CentOS/Fedora or Debian/Ubuntu)
- Root/sudo access
- USB UPS connected (for standalone/netserver modes)

## Finding Your USB UPS Port

Before running the role, you need to identify your UPS device. Run these commands on the target system:

### Method 1: Use nut-scanner (Recommended)

```bash
# Install NUT first if not present
sudo dnf install nut        # Fedora/RHEL
sudo apt install nut        # Debian/Ubuntu

# Scan for USB UPS devices
sudo nut-scanner -U
```

Example output:
```
[ups]
    driver = "usbhid-ups"
    port = "auto"
    vendorid = "051D"
    productid = "0002"
    product = "Back-UPS RS 1500G"
    serial = "3B1234X56789"
    bus = "001"
```

### Method 2: List USB Devices

```bash
# List all USB devices
lsusb

# Filter for common UPS vendors
lsusb | grep -iE "apc|cyberpower|eaton|tripp|belkin|liebert"
```

Example output:
```
Bus 001 Device 002: ID 051d:0002 American Power Conversion Uninterruptible Power Supply
```

The ID `051d:0002` shows **vendorid:productid**.

### Method 3: Check USB HID Devices

```bash
# List HID devices (many UPS use HID protocol)
ls -la /dev/usb/hiddev*
ls -la /dev/hidraw*
```

### Method 4: Check Kernel Messages

```bash
# View recent USB device connections
dmesg | grep -i ups
dmesg | grep -i hid
dmesg | tail -50  # After plugging in UPS
```

### Method 5: Use udevadm

```bash
# Get detailed USB device info
udevadm info -a -n /dev/usb/hiddev0

# Monitor USB events (plug/unplug UPS to see)
udevadm monitor --subsystem-match=usb
```

## Role Variables

### Required Variables

You **MUST** define these variables in your playbook or host_vars (use Ansible Vault for passwords):

```yaml
nut_upsd_users:
  - username: "upsmon"
    password: "{{ vault_nut_upsmon_password }}"
    upsmon: "primary"

nut_upsmon_monitors:
  - ups: "{{ nut_ups_name }}@localhost"
    powervalue: 1
    username: "upsmon"
    password: "{{ vault_nut_upsmon_password }}"
    type: "primary"
```

For UPS settings control (optional), add an admin user:

```yaml
nut_upsd_users:
  - username: "upsmon"
    password: "{{ vault_nut_upsmon_password }}"
    upsmon: "primary"
  - username: "admin"
    password: "{{ vault_nut_admin_password }}"
    instcmds:
      - all
    actions:
      - set
      - fsd
```

### Installation Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `nut_install_enabled` | Enable NUT installation | `true` |
| `nut_mode` | Operating mode: `standalone`, `netserver`, `netclient`, `none` | `standalone` |

### UPS Device Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `nut_ups_name` | Name for your UPS | `ups` |
| `nut_ups_driver` | UPS driver to use | `usbhid-ups` |
| `nut_ups_port` | UPS port/connection | `auto` |
| `nut_ups_description` | UPS description | `Main UPS` |
| `nut_ups_driver_options` | Additional driver options (dict) | `{}` |

#### Common Drivers

| Driver | Use Case |
|--------|----------|
| `usbhid-ups` | Most USB UPS (APC, CyberPower, Eaton) |
| `blazer_usb` | Megatec/Q1 protocol USB devices |
| `nutdrv_qx` | Modern replacement for blazer |
| `snmp-ups` | Network SNMP UPS |
| `apcsmart` | APC Smart-UPS via serial |

### Port Values

| Value | Description |
|-------|-------------|
| `auto` | Let NUT auto-detect (recommended for USB) |
| `/dev/usb/hiddev0` | Specific HID device |
| `/dev/bus/usb/001/002` | Specific USB bus/device path |
| `192.168.1.100` | IP address (for SNMP UPS) |

### Network Server Configuration (netserver mode)

| Variable | Description | Default |
|----------|-------------|---------|
| `nut_upsd_listen` | Listen addresses | `[{address: "127.0.0.1", port: 3493}]` |
| `nut_upsd_maxage` | Max data age (seconds) | `15` |
| `nut_firewall_enabled` | Open firewall port | `false` |
| `nut_firewall_port` | Port to open | `3493` |

### Monitor Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `nut_upsmon_minsupplies` | Min power supplies needed | `1` |
| `nut_upsmon_shutdowncmd` | Shutdown command | `/sbin/shutdown -h +0` |
| `nut_upsmon_pollfreq` | Polling interval (seconds) | `5` |
| `nut_upsmon_deadtime` | Seconds before UPS declared dead | `15` |

### Service Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `nut_services_enabled` | Enable services at boot | `true` |
| `nut_services_started` | Start services immediately | `true` |
| `nut_install_scanner_libs` | Install optional nut-scanner libraries (SNMP, Avahi, IPMI) | `true` |

> **Note:** Service names are auto-detected based on OS family:
> - **Debian/Ubuntu**: Uses `nut-driver.target`, `nut-server`, `nut-monitor`
> - **RedHat/Fedora**: Uses `nut-driver`, `nut-server`, `nut-monitor`
>
> You can override these with `nut_driver_service`, `nut_server_service`, `nut_monitor_service` if needed.

## Dependencies

None.

## Example Playbooks

### Basic Standalone Setup

```yaml
---
- name: Configure UPS monitoring
  hosts: servers
  become: true
  vars:
    nut_ups_port: "auto"
    nut_upsd_users:
      - username: "upsmon"
        password: "{{ vault_nut_upsmon_password }}"
        upsmon: "primary"
    nut_upsmon_monitors:
      - ups: "ups@localhost"
        powervalue: 1
        username: "upsmon"
        password: "{{ vault_nut_upsmon_password }}"
        type: "primary"
  roles:
    - brcak_zmaj.almir_ansible.NUT
```

### With Specific USB Device

```yaml
---
- name: Configure UPS with specific device
  hosts: servers
  become: true
  vars:
    nut_ups_name: "apc-1500"
    nut_ups_driver: "usbhid-ups"
    nut_ups_port: "auto"
    nut_ups_description: "APC Back-UPS RS 1500"
    nut_ups_driver_options:
      vendorid: "051d"
      productid: "0002"
    nut_upsd_users:
      - username: "upsmon"
        password: "{{ vault_nut_password }}"
        upsmon: "primary"
    nut_upsmon_monitors:
      - ups: "apc-1500@localhost"
        powervalue: 1
        username: "upsmon"
        password: "{{ vault_nut_password }}"
        type: "primary"
  roles:
    - brcak_zmaj.almir_ansible.NUT
```

### Network Server (Share UPS with Other Machines)

```yaml
---
- name: Configure NUT server
  hosts: ups_server
  become: true
  vars:
    nut_mode: "netserver"
    # Use 0.0.0.0 to listen on all interfaces (includes localhost)
    # Don't use both 127.0.0.1 and 0.0.0.0 - they conflict
    nut_upsd_listen:
      - address: "0.0.0.0"
        port: 3493
    nut_firewall_enabled: true
    nut_upsd_users:
      - username: "upsmon"
        password: "{{ vault_nut_password }}"
        upsmon: "primary"
      - username: "upsmon_remote"
        password: "{{ vault_nut_remote_password }}"
        upsmon: "secondary"
    nut_upsmon_monitors:
      - ups: "ups@localhost"
        powervalue: 1
        username: "upsmon"
        password: "{{ vault_nut_password }}"
        type: "primary"
  roles:
    - brcak_zmaj.almir_ansible.NUT
```

### Network Client (Monitor Remote UPS)

```yaml
---
- name: Configure NUT client
  hosts: other_servers
  become: true
  vars:
    nut_mode: "netclient"
    nut_upsmon_monitors:
      - ups: "ups@ups-server.example.com"
        powervalue: 1
        username: "upsmon_remote"
        password: "{{ vault_nut_remote_password }}"
        type: "secondary"
  roles:
    - brcak_zmaj.almir_ansible.NUT
```

### Multiple UPS Devices

```yaml
---
- name: Configure multiple UPS
  hosts: data_center
  become: true
  vars:
    nut_mode: "netserver"
    nut_ups_devices:
      - name: "ups-rack1"
        driver: "usbhid-ups"
        port: "auto"
        description: "Rack 1 UPS"
        options:
          vendorid: "051d"
          serial: "ABC123"
      - name: "ups-rack2"
        driver: "snmp-ups"
        port: "192.168.1.50"
        description: "Rack 2 Network UPS"
        options:
          community: "public"
          snmp_version: "v2c"
    nut_upsmon_monitors:
      - ups: "ups-rack1@localhost"
        powervalue: 1
        username: "upsmon"
        password: "{{ vault_nut_password }}"
        type: "primary"
      - ups: "ups-rack2@localhost"
        powervalue: 1
        username: "upsmon"
        password: "{{ vault_nut_password }}"
        type: "primary"
  roles:
    - brcak_zmaj.almir_ansible.NUT
```

## Verifying the Setup

After running the playbook, verify NUT is working:

```bash
# Check UPS status
upsc ups@localhost

# List available UPS devices
upsc -l

# Check service status (Debian/Ubuntu)
systemctl status nut-driver.target nut-server nut-monitor

# Check service status (RedHat/Fedora)
systemctl status nut-driver nut-server nut-monitor

# Test UPS communication
upscmd -l ups@localhost

# View NUT logs (Debian - use actual UPS name)
journalctl -u nut-driver@ups -u nut-server -u nut-monitor

# View NUT logs (RedHat)
journalctl -u nut-driver -u nut-server -u nut-monitor
```

## Troubleshooting

### UPS Not Detected

1. Check USB connection:
   ```bash
   lsusb | grep -i ups
   ```

2. Verify permissions:
   ```bash
   ls -la /dev/usb/hiddev*
   # Should show group 'nut'
   ```

3. Reload udev rules:
   ```bash
   sudo udevadm control --reload-rules
   sudo udevadm trigger
   ```

4. Check driver manually:
   ```bash
   sudo upsdrvctl start
   ```

### Permission Denied Errors

Ensure the nut user has access to USB devices:

```bash
# Add nut to required groups
sudo usermod -a -G dialout,plugdev nut

# Restart services (Debian)
sudo systemctl restart nut-driver.target nut-server

# Restart services (RedHat)
sudo systemctl restart nut-driver nut-server
```

### Driver Won't Start

Check logs for specific errors:

```bash
sudo upsdrvctl -D start
journalctl -u nut-driver -f
```

## Prometheus Exporter (nut_exporter)

This role can optionally install [nut_exporter](https://github.com/DRuggeri/nut_exporter) to expose NUT metrics for Prometheus/Grafana monitoring.

### Exporter Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `nut_exporter_enabled` | Enable exporter installation | `false` |
| `nut_exporter_install_method` | `binary` or `docker` | `binary` |
| `nut_exporter_version` | Version to install | `latest` |
| `nut_exporter_port` | Metrics port | `9199` |
| `nut_exporter_nut_server` | NUT server address | `127.0.0.1` |
| `nut_exporter_nut_port` | NUT server port | `3493` |
| `nut_exporter_nut_username` | NUT authentication user | `""` |
| `nut_exporter_nut_password` | NUT authentication password | `""` |

### Binary Installation (Default)

```yaml
---
- name: Install NUT with Prometheus exporter
  hosts: ups_servers
  become: true
  vars:
    nut_exporter_enabled: true
    nut_exporter_install_method: "binary"
    nut_exporter_version: "latest"
    nut_exporter_port: 9199
  roles:
    - brcak_zmaj.almir_ansible.NUT
```

### Docker Installation

```yaml
---
- name: Install NUT with Docker exporter
  hosts: ups_servers
  become: true
  vars:
    nut_exporter_enabled: true
    nut_exporter_install_method: "docker"
    nut_exporter_version: "latest"
    nut_exporter_port: 9199
    nut_exporter_container_name: "nut_exporter"
    nut_exporter_docker_memory: "128m"
    nut_exporter_docker_cpus: 0.5
    nut_exporter_timezone: "America/New_York"
    # For Docker, use host IP if NUT is on same host
    nut_exporter_nut_server: "{{ ansible_host }}"
    nut_exporter_docker_networks:
      - name: "monitoring_network"
  roles:
    - brcak_zmaj.almir_ansible.NUT
```

### Prometheus Configuration

Add this scrape config to your Prometheus:

```yaml
scrape_configs:
  - job_name: 'nut'
    static_configs:
      - targets: ['ups-server:9199']
    metrics_path: /ups_metrics
```

### Grafana Dashboards

Several community dashboards are available:
- [NUT UPS Dashboard](https://grafana.com/grafana/dashboards/14371)
- Search Grafana.com for "NUT" or "UPS"

## Tags

- `nut` - All NUT tasks
- `nut-install` - Installation only
- `nut-config` - Configuration only
- `nut-service` - Service management only
- `nut-firewall` - Firewall rules only
- `nut-exporter` - Exporter tasks only
- `nut-ups-settings` - UPS hardware settings only
- `nut-ups-detect` - UPS detection only

## UPS Hardware Settings Configuration

This role can detect your UPS type and apply hardware settings via the `upsrw` command. This allows you to control:

- **Auto-restart delay** after power returns
- **Battery thresholds** for low battery state
- **Input voltage sensitivity**
- **Voltage transfer points**

### Prerequisites

1. Add an admin user with `actions: set` permission (see Required Variables above)
2. Enable UPS settings management

### Configuration Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `nut_ups_settings_enabled` | Enable UPS settings management | `false` |
| `nut_ups_admin_username` | Admin user for changing settings | `""` |
| `nut_ups_admin_password` | Admin password (use vault!) | `""` |
| `nut_ups_settings_no_log` | Hide passwords in output | `true` |
| `nut_ups_settings_debug` | Show debug info | `false` |
| `nut_ups_settings_verify` | Verify settings after applying | `true` |
| `nut_ups_settings` | List of settings to apply | `[]` |

### CyberPower UPS Available Settings

| Setting | Description | Default |
|---------|-------------|---------|
| `ups.delay.start` | Seconds before auto-restart after power returns | `120` |
| `ups.delay.shutdown` | Seconds before shutdown on command | `60` |
| `battery.charge.low` | Battery % for low battery state | `10` |
| `battery.runtime.low` | Runtime seconds for low battery | `300` |
| `input.sensitivity` | Voltage sensitivity: `low`, `normal`, `high` | `normal` |
| `input.transfer.high` | High voltage transfer point | `139` |
| `input.transfer.low` | Low voltage transfer point | `100` |

### Example: Configure CyberPower UPS

```yaml
---
- name: Configure CyberPower UPS with custom settings
  hosts: ups_server
  become: true
  vars:
    # Required users
    nut_upsd_users:
      - username: "upsmon"
        password: "{{ vault_nut_upsmon_password }}"
        upsmon: "primary"
      - username: "admin"
        password: "{{ vault_nut_admin_password }}"
        instcmds:
          - all
        actions:
          - set
          - fsd

    nut_upsmon_monitors:
      - ups: "{{ nut_ups_name }}@localhost"
        powervalue: 1
        username: "upsmon"
        password: "{{ vault_nut_upsmon_password }}"
        type: "primary"

    # Enable UPS settings management
    nut_ups_settings_enabled: true
    nut_ups_admin_username: "admin"
    nut_ups_admin_password: "{{ vault_nut_admin_password }}"

    # CyberPower UPS settings
    nut_ups_settings:
      # Fast auto-restart (60 seconds after power returns)
      - variable: "ups.delay.start"
        value: "60"
      # Shutdown at 15% battery
      - variable: "battery.charge.low"
        value: "15"
      # Or shutdown with 3 minutes runtime left
      - variable: "battery.runtime.low"
        value: "180"
      # High sensitivity for sensitive equipment
      - variable: "input.sensitivity"
        value: "high"

  roles:
    - brcak_zmaj.almir_ansible.NUT
```

### Discovering Available Settings

To see what settings your UPS supports, run on the target system:

```bash
# List all writable variables
upsrw ups@localhost

# List all available commands
upscmd -l ups@localhost

# View current UPS status
upsc ups@localhost
```

### Manual Setting Changes

You can also change settings manually without running the playbook:

```bash
# Change auto-restart delay to 60 seconds
upsrw -s ups.delay.start=60 -u admin -p PASSWORD ups@localhost

# Disable beeper
upscmd -u admin -p PASSWORD ups@localhost beeper.disable

# Run battery test
upscmd -u admin -p PASSWORD ups@localhost test.battery.start.quick
```

## NUT Exporter (Prometheus)

This role can install and configure the [nut_exporter](https://github.com/DRuggeri/nut_exporter) to expose UPS metrics for Prometheus/Grafana.

- Installation methods: binary (default) or Docker
- Configurable listen address/port, metrics path, and variables
- Works with local NUT server (default 127.0.0.1:3493)

### Multi-UPS Scraping Requirement

When multiple UPS devices are connected to the same NUT server, `nut_exporter` requires the UPS name to be specified via a query parameter on the metrics endpoint. Without this, the endpoint will return HTTP 500 with `empty metric collected`.

Scrape each UPS separately, e.g.:

```
http://<host>:9199/ups_metrics?ups=ups-primary
http://<host>:9199/ups_metrics?ups=ups-secondary
```

Prometheus/Alloy scrape examples:

```river
prometheus.scrape "nut_exporter_primary" {
  targets      = ["<host>:9199"]
  metrics_path = "/ups_metrics"
  params       = { ups = ["ups-primary"] }
  forward_to   = [prometheus.remote_write.metrics_out.receiver]
}

prometheus.scrape "nut_exporter_secondary" {
  targets      = ["<host>:9199"]
  metrics_path = "/ups_metrics"
  params       = { ups = ["ups-secondary"] }
  forward_to   = [prometheus.remote_write.metrics_out.receiver]
}
```

Note: The binary exporter does not accept an `--ups` flag; use the query parameter or run separate exporter instances per UPS on different ports.

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
