<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/d/d1/Raspberry_Pi_OS_Logo.png/840px-Raspberry_Pi_OS_Logo.png" width="600" height="180" alt="Raspberry Pi Logo" />


# almir.RaspberryPi

A comprehensive Ansible role for configuring Raspberry Pi 3, 4, and 5 devices with extensive configuration options for swap management, logging optimization, power management, boot settings, hardware interfaces, and system tuning. This role is designed to be production-ready and includes optimizations specifically for SD card longevity.

## Features

This role provides comprehensive configuration management for Raspberry Pi devices, including:

### 🔄 Swap Management
- Enable/disable swap with configurable file size
- Set swappiness and VFS cache pressure for optimal SD card performance
- Automatic swap file creation and `/etc/fstab` management
- Optimized defaults for SD card longevity (low swappiness)

### 📝 Logging Management (SD Card Wear Reduction)
- **Systemd Journald**: Configure volatile storage (RAM only) to eliminate SD card writes
- **Syslog**: Automatic log rotation and compression
- **Logrotate**: Comprehensive log rotation configuration
- Configurable retention periods and size limits
- All optimizations designed to minimize SD card wear

### ⚡ Power Management
- Power LED configuration (Pi 4/5)
- Activity LED configuration with customizable triggers
- WiFi and USB power saving options
- Undervolting support for advanced users

### 🚀 Boot Configuration (`/boot/config.txt`)
- **GPU Memory Split**: Configurable GPU memory allocation
- **Overclocking**: Model-specific overclocking for Pi 3, 4, and 5
- **Display/HDMI**: Resolution, mode, and CEC configuration
- **Audio**: Audio driver and PWM mode configuration
- **Camera Module**: Enable/disable camera interface and LED
- **GPIO**: GPIO pull configuration
- **USB**: USB power and current limits
- **Boot Options**: Boot delay, splash screen, network wait
- **Custom Options**: Add any custom `config.txt` or `cmdline.txt` parameters

### 🌐 Network Configuration
- WiFi country code configuration
- WiFi power management settings
- Bluetooth enable/disable and pairable settings

### ⚙️ System Optimizations
- **Filesystem**: `noatime` mount option to reduce writes
- **CPU Governor**: Configurable CPU frequency scaling (ondemand, performance, powersave, conservative)
- **I/O Scheduler**: Optimized I/O scheduler for SD cards (mq-deadline recommended)
- **TRIM**: Weekly automatic TRIM for SD cards
- **Ext4 Commit**: Configurable filesystem commit intervals

### 🔌 Hardware Interfaces
- **Watchdog Timer**: Hardware watchdog with configurable timeout
- **I2C**: Enable I2C interface with configurable baudrate
- **SPI**: Enable SPI interface
- **UART**: Serial console and UART configuration
- **1-Wire**: Enable 1-Wire interface for sensors

### 🔒 Security Configuration
- **SSH**: Password authentication, root login, and port configuration
- **Firewall**: UFW firewall management with customizable rules

### 📦 Additional Features
- **Package Management**: Install system and optional packages
- **Timezone/Locale**: Configure system timezone, locale, and keyboard layout
- **Temperature Monitoring**: Optional temperature monitoring with cron-based logging
- **Model Auto-Detection**: Automatic detection of Pi 3, 4, or 5 from device tree

## Requirements

### Ansible Version Compatibility

This role is tested and supported with:
- **Ansible**: `>= 2.9`
- **Python**: `>= 3.6` (on target system)

### Target System Requirements

- **OS**: Raspberry Pi OS (Debian-based) - Bullseye or later recommended
- **Architecture**: ARM (armhf or arm64)
- **Access**: SSH access with sudo/root privileges
- **Python**: Python 3 installed on target system

### Supported Raspberry Pi Models

- ✅ **Raspberry Pi 3** (Model B, B+, A+)
- ✅ **Raspberry Pi 4** (all variants)
- ✅ **Raspberry Pi 5** (all variants)

The role automatically detects the Raspberry Pi model from `/proc/device-tree/model`. You can also manually specify the model using the `rpi_model` variable.

## Installation

### From Ansible Galaxy

```bash
ansible-galaxy role install almir.RaspberryPi
```

### Using in a Collection

If you're using this role as part of the `brcak_zmaj.almir_ansible` collection:

```bash
ansible-galaxy collection install brcak_zmaj.almir_ansible
```

Then reference it in your playbook as:

```yaml
roles:
  - role: brcak_zmaj.almir_ansible.raspberry_pi
```

## Quick Start

### Basic Usage

```yaml
---
- hosts: raspberry_pi
  become: yes
  roles:
    - almir.RaspberryPi
  vars:
    rpi_swap_enable: true
    rpi_swap_size_mb: 100
    rpi_journald_storage: volatile
    rpi_gpu_mem: 128
```

### Minimal Configuration (SD Card Optimized)

```yaml
---
- hosts: raspberry_pi
  become: yes
  roles:
    - almir.RaspberryPi
  vars:
    rpi_swap_enable: false          # Disable swap for SD card longevity
    rpi_journald_storage: volatile  # RAM only - no SD card writes
    rpi_fs_noatime: true            # No access time updates
    rpi_fs_trim_enable: true        # Weekly TRIM
```

## Role Variables

All configuration is done via variables in `defaults/main.yml`. All variables can be overridden in your playbook or inventory.

### Swap Configuration

```yaml
rpi_swap_manage: true              # Enable swap management
rpi_swap_enable: true              # Enable/disable swap
rpi_swap_size_mb: 100              # Swap file size in MB
rpi_swap_file: /var/swap           # Swap file location
rpi_swap_swappiness: 10            # Swappiness (0-100, lower = less swap usage)
rpi_swap_vfs_cache_pressure: 50    # VFS cache pressure (1-100)
```

**Recommended for SD cards**: `rpi_swap_swappiness: 10` or lower to minimize swap usage.

### Logging Configuration

```yaml
rpi_logging_manage: true           # Enable logging management

# Systemd Journald
rpi_journald_enable: true
rpi_journald_storage: volatile      # persistent, volatile, auto, none
                                    # volatile = RAM only (best for SD cards)
rpi_journald_max_use: 50M           # Maximum disk space for journal
rpi_journald_max_file_size: 10M     # Maximum size per journal file
rpi_journald_max_retention_days: 3  # Maximum days to retain logs
rpi_journald_compress: true         # Compress old journal files

# Syslog
rpi_syslog_manage: true
rpi_syslog_rotate: true
rpi_syslog_max_size: 10M
rpi_syslog_rotate_count: 3
rpi_syslog_compress: true

# Logrotate
rpi_logrotate_enable: true
rpi_logrotate_weekly: true
rpi_logrotate_rotate: 4
rpi_logrotate_compress: true
```

**Recommended for SD cards**: Use `volatile` storage for journald to eliminate SD card writes.

### Power Management

```yaml
rpi_power_manage: true
rpi_power_led_enable: true         # Enable power LED (Pi 4/5)
rpi_power_led_trigger: default     # default, heartbeat, none
rpi_activity_led_enable: true      # Enable activity LED
rpi_activity_led_trigger: mmc0     # mmc0, cpu0, default, none
rpi_power_save_enable: false       # Enable power saving mode
rpi_power_save_wifi: false         # WiFi power saving
rpi_power_save_usb: false          # USB power saving
```

### Boot Configuration

```yaml
rpi_boot_config_manage: true

# GPU Memory
rpi_gpu_mem: 128                   # GPU memory in MB (64, 128, 256, 512)

# Overclocking (Pi 3/4)
rpi_overclock_enable: false
rpi_overclock_arm_freq: 1500       # ARM CPU frequency (MHz)
rpi_overclock_arm_freq_min: 600    # Minimum ARM frequency
rpi_overclock_gpu_freq: 500        # GPU frequency (MHz)
rpi_overclock_sdram_freq: 500      # SDRAM frequency (MHz)
rpi_overclock_voltage: 0           # Overvoltage (0-6, 0.025V steps)
rpi_overclock_force_turbo: false   # Force turbo (may void warranty)

# Pi 5 Overclocking
rpi5_overclock_enable: false
rpi5_arm_freq: 2400               # Pi 5 ARM frequency (MHz, default: 2400)
rpi5_gpu_freq: 800                # Pi 5 GPU frequency (MHz, default: 800)

# Display/HDMI
rpi_display_enable: true
rpi_hdmi_group: 2                 # 1=CEA, 2=DMT
rpi_hdmi_mode: 82                 # 82=1920x1080 60Hz
rpi_hdmi_force_hotplug: false
rpi_hdmi_ignore_edid: false
rpi_hdmi_drive: 2                 # 1=DVI, 2=HDMI
rpi_hdmi_ignore_cec: false

# Audio
rpi_audio_enable: true
rpi_audio_driver: "vc4-kms-v3d"   # Pi 4/5: vc4-kms-v3d, Pi 3: on
rpi_audio_pwm_mode: 2             # 0=auto, 1=stereo, 2=quad

# Camera
rpi_camera_enable: false
rpi_camera_disable_led: false

# GPIO
rpi_gpio_enable: true
rpi_gpio_pull: "up"               # up, down, off

# USB
rpi_usb_max_current: 1            # USB max current (amps, Pi 4: 1.2A default)
rpi_usb_power_mode: "default"     # default, on, off

# Boot Options
rpi_boot_delay: 1                 # Boot delay (seconds)
rpi_boot_wait: false              # Wait for network before boot
rpi_boot_splash: true             # Enable boot splash screen
rpi_boot_quiet: false             # Quiet boot

# Custom Options
rpi_config_custom: []             # Custom config.txt options
                                  # Example: ["dtparam=i2c_arm=on", "dtparam=spi=on"]
rpi_cmdline_custom: []            # Custom cmdline.txt options
                                  # Example: ["cgroup_enable=cpuset", "cgroup_memory=1"]
```

### Network Configuration

```yaml
rpi_network_manage: true
rpi_wifi_enable: true
rpi_wifi_country: "US"            # WiFi country code (US, GB, etc.)
rpi_wifi_power_management: false  # WiFi power management
rpi_bluetooth_enable: true
rpi_bluetooth_pairable: false
```

### System Optimizations

```yaml
rpi_system_optimize: true
rpi_fs_trim_enable: true          # Enable TRIM for SD cards (weekly)
rpi_fs_noatime: true              # Mount with noatime (reduce writes)
rpi_fs_commit: 5                  # Ext4 commit interval (seconds)
rpi_cpu_governor: "ondemand"      # ondemand, performance, powersave, conservative
rpi_cpu_min_freq: 600             # Minimum CPU frequency (MHz)
rpi_cpu_max_freq: 0               # Maximum CPU frequency (0=auto, MHz)
rpi_io_scheduler: "mq-deadline"   # mq-deadline, bfq, none, kyber
```

### Hardware Interfaces

```yaml
rpi_hardware_manage: true
rpi_watchdog_enable: false      # Enable hardware watchdog
rpi_watchdog_timeout: 15        # Watchdog timeout (seconds)
rpi_i2c_enable: false           # Enable I2C interface
rpi_i2c_baudrate: 100000        # I2C baudrate
rpi_spi_enable: false           # Enable SPI interface
rpi_uart_enable: false          # Enable UART
rpi_uart_console: false         # Enable UART console
rpi_onewire_enable: false       # Enable 1-Wire interface
```

### Security Configuration

```yaml
rpi_security_manage: true
rpi_ssh_enable: true
rpi_ssh_password_auth: false         # Allow password authentication
rpi_ssh_root_login: false            # Allow root login
rpi_ssh_port: 22                     # SSH port
rpi_firewall_enable: false           # Enable UFW firewall
rpi_firewall_default_policy: "deny"  # allow, deny
rpi_firewall_rules: []               # Example: ["22/tcp", "80/tcp", "443/tcp"]
                                
```

### Package Management

```yaml
rpi_packages_install: true
rpi_packages_update: true
rpi_system_packages:
  - htop
  - vim
  - git
  - curl
  - wget
  - build-essential
  - python3-pip
  - python3-dev
rpi_optional_packages: []       # Additional packages to install
```

### Timezone and Locale

```yaml
rpi_locale_manage: true
rpi_timezone: "America/New_York"  # Timezone (tzdata format)
rpi_locale: "en_US.UTF-8"         # Locale
rpi_keyboard_layout: "us"         # Keyboard layout
```

### Temperature Monitoring

```yaml
rpi_temp_monitor_enable: false   # Enable temperature monitoring
rpi_temp_warning: 70             # Warning temperature (°C)
rpi_temp_critical: 80            # Critical temperature (°C)
rpi_temp_throttle: 85            # Throttle temperature (°C)
```

### Model Detection

```yaml
rpi_model: auto                 # auto, pi3, pi4, pi5
```

The role automatically detects the Raspberry Pi model. You can override this by setting `rpi_model` to `pi3`, `pi4`, or `pi5`.

## Example Playbooks

### Basic Configuration

```yaml
---
- hosts: raspberry_pi
  become: yes
  roles:
    - almir.RaspberryPi
  vars:
    rpi_swap_enable: true
    rpi_swap_size_mb: 100
    rpi_journald_storage: volatile
    rpi_gpu_mem: 128
    rpi_fs_noatime: true
```

### High Performance (Pi 4/5)

```yaml
---
- hosts: raspberry_pi
  become: yes
  roles:
    - almir.RaspberryPi
  vars:
    rpi_overclock_enable: true
    rpi_overclock_arm_freq: 2000
    rpi_cpu_governor: "performance"
    rpi_gpu_mem: 256
    rpi_fs_noatime: true
```

### SD Card Optimized (Maximum Longevity)

```yaml
---
- hosts: raspberry_pi
  become: yes
  roles:
    - almir.RaspberryPi
  vars:
    # Disable swap completely
    rpi_swap_enable: false
    
    # Use volatile journald (RAM only)
    rpi_journald_storage: volatile
    rpi_journald_max_retention_days: 1
    
    # Filesystem optimizations
    rpi_fs_noatime: true
    rpi_fs_trim_enable: true
    rpi_fs_commit: 10  # Longer commit interval
    
    # Aggressive log rotation
    rpi_logrotate_enable: true
    rpi_logrotate_rotate: 2  # Keep fewer logs
    rpi_syslog_rotate_count: 2
    
    # Low swappiness if swap is needed
    rpi_swap_swappiness: 1
```

### Media Center (Pi 4/5)

```yaml
---
- hosts: raspberry_pi
  become: yes
  roles:
    - almir.RaspberryPi
  vars:
    rpi_gpu_mem: 256              # More GPU memory for video
    rpi_hdmi_mode: 82             # 1920x1080 60Hz
    rpi_audio_enable: true
    rpi_cpu_governor: "ondemand"
    rpi_journald_storage: volatile
```

### IoT/Sensor Project

```yaml
---
- hosts: raspberry_pi
  become: yes
  roles:
    - almir.RaspberryPi
  vars:
    # Enable hardware interfaces
    rpi_i2c_enable: true
    rpi_spi_enable: true
    rpi_onewire_enable: true
    rpi_uart_enable: true
    
    # SD card optimizations
    rpi_swap_enable: false
    rpi_journald_storage: volatile
    rpi_fs_noatime: true
    
    # Temperature monitoring
    rpi_temp_monitor_enable: true
    rpi_temp_warning: 60
    rpi_temp_critical: 75
```

### Custom Configuration

```yaml
---
- hosts: raspberry_pi
  become: yes
  roles:
    - almir.RaspberryPi
  vars:
    # Custom config.txt options
    rpi_config_custom:
      - "dtparam=i2c_arm=on"
      - "dtparam=spi=on"
      - "dtoverlay=vc4-kms-v3d"
      - "dtoverlay=w1-gpio"
    
    # Custom cmdline.txt options
    rpi_cmdline_custom:
      - "cgroup_enable=cpuset"
      - "cgroup_memory=1"
      - "cgroup_enable=memory"
```

## Available Tags

You can use tags to run specific parts of the role:

```bash
# Configure only swap
ansible-playbook playbook.yml --tags swap

# Configure only logging
ansible-playbook playbook.yml --tags logging

# Configure only boot settings
ansible-playbook playbook.yml --tags boot

# Configure only system optimizations
ansible-playbook playbook.yml --tags optimize
```

Available tags:
- `swap` - Swap configuration
- `logging` - Logging configuration
- `power` - Power management
- `boot` - Boot configuration
- `network` - Network configuration
- `optimize` - System optimizations
- `hardware` - Hardware interfaces
- `security` - Security configuration
- `packages` - Package installation
- `locale` - Timezone/locale

## Dependencies

This role has no external dependencies. All required system packages are installed by the role itself.

## Model-Specific Notes

### Raspberry Pi 3
- Default GPU memory: 128MB
- Safe overclock: up to 1400MHz ARM
- No USB power management options

### Raspberry Pi 4
- Default GPU memory: 128MB (can go up to 512MB)
- Safe overclock: up to 2147MHz ARM (with adequate cooling)
- USB power management available
- Power LED configuration available

### Raspberry Pi 5
- Default GPU memory: 128MB (can go up to 512MB)
- Default ARM frequency: 2400MHz
- Overclocking requires active cooling (not recommended without proper cooling)
- Power LED configuration available
- Different audio driver (vc4-kms-v3d)

## Troubleshooting

### Check Model Detection

```bash
cat /proc/device-tree/model
```

The role should automatically detect your model. If it doesn't, you can manually set `rpi_model: pi3|pi4|pi5`.

### Verify Configuration

```bash
# Check config.txt
cat /boot/config.txt

# Check swap
swapon --show
cat /proc/sys/vm/swappiness

# Check journald
journalctl --disk-usage
cat /etc/systemd/journald.conf.d/99-rpi-optimize.conf

# Check temperature
vcgencmd measure_temp

# Check CPU governor
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Check I/O scheduler
cat /sys/block/mmcblk0/queue/scheduler
```

### Common Issues

1. **Swap not working**
   - Ensure sufficient disk space: `df -h`
   - Check swap file exists: `ls -lh /var/swap`
   - Verify swap is enabled: `swapon --show`

2. **Journald not volatile**
   - Check configuration: `cat /etc/systemd/journald.conf.d/99-rpi-optimize.conf`
   - Restart journald: `systemctl restart systemd-journald`
   - Verify storage: `journalctl --disk-usage`

3. **Overclocking not applied**
   - Overclocking requires a reboot to take effect
   - Verify config.txt: `grep -E "arm_freq|gpu_freq" /boot/config.txt`
   - Check for throttling: `vcgencmd get_throttled`

4. **GPIO/I2C/SPI not working**
   - Ensure interface is enabled in config.txt
   - Check device tree: `ls /dev/i2c-* /dev/spi*`
   - Verify modules are loaded: `lsmod | grep -E "i2c|spi"`

5. **Temperature monitoring not working**
   - Ensure `vcgencmd` is available: `which vcgencmd`
   - Check script permissions: `ls -l /usr/local/bin/rpi-temp-monitor.sh`
   - Check cron job: `crontab -l | grep temp`

## Important Notes

### Reboot Required

Many boot configuration changes (overclocking, GPU memory, display settings, hardware interfaces) require a **reboot** to take effect. The role will not automatically reboot the system.

### SD Card Wear

For maximum SD card longevity:
- Use `rpi_journald_storage: volatile` (RAM only)
- Disable swap: `rpi_swap_enable: false`
- Use `rpi_fs_noatime: true`
- Enable TRIM: `rpi_fs_trim_enable: true`
- Use low swappiness if swap is needed: `rpi_swap_swappiness: 1`

### Overclocking

- **May void warranty**: Overclocking may void your Raspberry Pi warranty
- **Cooling required**: Ensure adequate cooling, especially for Pi 4/5
- **Pi 5 overclocking**: Requires active cooling, not recommended without proper cooling solution
- **Stability**: Test overclocking settings thoroughly before deploying to production

### Idempotency

All tasks in this role are idempotent. You can run the role multiple times without unintended side effects.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## License

GPL-3.0-or-later

> Note: I am providing code in the repository to you under an open source license. Because this is my personal repository, the license you receive to my code is from me and not my employer.

## Author Information

This role is part of the `brcak_zmaj.almir_ansible` Ansible collection.

**GitHub**: [brcak-zmaj/almir.ansible](https://github.com/brcak-zmaj/almir.ansible)
- Almir Zohorovic

## Support

For issues, questions, or contributions, please use the [GitHub Issues](https://github.com/brcak-zmaj/almir.ansible/issues) page.

## Changelog

### Version 1.0.0
- Initial release
- Support for Raspberry Pi 3, 4, and 5
- Comprehensive swap, logging, power, boot, network, and hardware configuration
- SD card wear reduction optimizations
- Model auto-detection
- Temperature monitoring
- Security configuration

## Stats

![Alt](https://repobeats.axiom.co/api/embed/7a7fe37d43ef2cab7bdbc23ba8c5cfe3cfbdf832.svg "Repobeats analytics image")
