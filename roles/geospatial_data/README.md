# Ansible Role - Geospatial Data

Ansible role for installing geospatial software and downloading offline map data on Linux systems.

## Overview

This role provides comprehensive geospatial capabilities for Linux systems, including installation of GIS software (QGIS, Marble, Viking), downloading various offline map datasets (OpenStreetMap, elevation data, topographic maps, nautical charts), and GPS hardware support. The role is designed for disconnected operations and offline mapping scenarios.

## Requirements

### Ansible Version Compatibility

- **Ansible**: `>= 2.9`
- **Python**: `>= 3.6` (on target system)

### Target System Requirements

- **OS**: Linux distributions (tested on Fedora, RHEL, CentOS; should work on Debian/Ubuntu with package manager adjustments)
- **Access**: SSH access with sudo/root privileges
- **Python**: Python 3 installed on target system
- **Disk Space**: Sufficient space for map data downloads (varies by selected datasets)
- **Package Manager**: DNF (Fedora/RHEL/CentOS) when not using Flatpak

### Dependencies

- **community.general** collection (required for Flatpak modules)

Install the collection:
```bash
ansible-galaxy collection install community.general
```

## Features

### Geospatial Software Installation

- **QGIS Desktop** - Full-featured Geographic Information System
  - Install via Flatpak (preferred) or system package manager
  - Individual enable/disable control
- **Marble Virtual Globe** - Virtual globe and world atlas
  - Install via Flatpak (preferred) or system package manager
  - Individual enable/disable control
- **Viking GPS Data Editor** - GPS data editor and analyzer
  - Install via Flatpak (preferred) or system package manager
  - Individual enable/disable control

### Package Manager Support

- **Flatpak Installation**: Automatic Flatpak installation and Flathub repository configuration
- **System Package Manager Fallback**: Automatic fallback to system package manager (DNF/APT/etc.) when Flatpak is disabled
- **Flexible Configuration**: Choose between Flatpak (preferred) or system package manager installation methods

### Offline Map Data Downloads

#### OpenStreetMap (OSM)
- **Regional Extracts**: Download regional PBF files from Geofabrik
- **Full Planet File**: Option to download complete planet file (~84GB)
- **Idempotent Downloads**: Skips existing files automatically
- **Default Regions**: North America, Europe, Bosnia-Herzegovina, Georgia (US)

#### Elevation Data
- **SRTM**: Shuttle Radar Topography Mission elevation data
  - 1arc resolution (30m, best quality) or 3arc resolution (90m, smaller files)
  - Tile-based downloads with configurable regions
- **ASTER**: Advanced Spaceborne Thermal Emission and Reflection Radiometer elevation data
  - 30m resolution global coverage
  - Tile-based downloads with configurable regions

#### Topographic Maps
- **USGS Topo Maps**: US Geological Survey topographic maps
  - Multiple scales: 250k (overview), 100k (detailed), 24k (very detailed)
  - State/region-based downloads

#### Nautical Charts
- **NOAA Charts**: National Oceanic and Atmospheric Administration nautical charts
  - Electronic Navigational Charts (ENC)
  - Raster Navigational Charts (RNC)
  - Region-specific chart downloads

#### MBTiles
- **Pre-rendered Tiles**: MBTiles format for mobile apps and web viewers
- **Custom Sources**: Configure custom MBTiles sources via URLs

### GPS Hardware Support

- **gpsd**: GPS daemon installation and configuration
- **gpsd-clients**: GPS client tools (cgps, xgps)
- **Device Configuration**: Configurable GPS device path (default: `/dev/ttyUSB0`)
- **Service Management**: Optional service enablement (disabled by default)
- **Hardware Support**: USB GPS, serial GPS, and SDR GPS devices

## Role Variables

All configuration variables are defined in `defaults/main.yml`. Key variables:

### User Configuration

| Variable Name | Description | Default Value |
|---------------|-------------|---------------|
| `user` | System user | `almir` |
| `home` | User home directory | `/home/{{ user }}` |
| `scripts_dir` | Scripts directory | `{{ home }}/scripts` |
| `data_dir` | Data storage directory | `{{ home }}/data` |

### Task Control

| Variable Name | Description | Default Value |
|---------------|-------------|---------------|
| `install_geospatial_software` | Install geospatial software (QGIS, Marble, Viking) | `true` |
| `install_map_data` | Download offline map datasets | `true` |
| `install_gps_support` | Install GPS daemon and hardware support | `true` |

### Package Manager Configuration

| Variable Name | Description | Default Value |
|---------------|-------------|---------------|
| `use_flatpak` | Use Flatpak for software installation (preferred) | `true` |
| `install_flatpak` | Install Flatpak package manager | `true` |
| `add_flathub` | Add Flathub repository | `true` |
| `verify_dependencies` | Verify installed dependencies | `true` |

### Individual Software Control

| Variable Name | Description | Default Value |
|---------------|-------------|---------------|
| `install_qgis` | Install QGIS Desktop | `true` |
| `install_marble` | Install Marble Virtual Globe | `true` |
| `install_viking` | Install Viking GPS Data Editor | `true` |

### Map Data Configuration

| Variable Name | Description | Default Value |
|---------------|-------------|---------------|
| `map_data_dir` | Directory for map data | `{{ data_dir }}/maps` |
| `osm_enabled` | Enable OpenStreetMap downloads | `true` |
| `osm_download_regions` | Download regional extracts from Geofabrik | `true` |
| `osm_download_planet` | Download full planet file (~84GB) | `false` |
| `osm_regions` | List of OSM regions to download | `["north-america", "europe", "europe/bosnia-herzegovina", "us/georgia"]` |
| `osm_extract_url` | OpenStreetMap extract URL | `https://download.geofabrik.de` |
| `mbtiles_enabled` | Enable MBTiles downloads | `true` |
| `mbtiles_regions` | List of MBTiles regions | `["north-america", "europe"]` |
| `mbtiles_sources` | List of MBTiles sources with URLs | `[]` |
| `srtm_enabled` | Enable SRTM elevation data downloads | `true` |
| `srtm_regions` | List of SRTM tile identifiers (e.g., "N34W084") | `["N34W084", "N44E018", "N44E017", "N43E018"]` |
| `srtm_resolution` | SRTM resolution: "1arc" (30m) or "3arc" (90m) | `"1arc"` |
| `aster_enabled` | Enable ASTER elevation data downloads | `true` |
| `aster_regions` | List of ASTER tile identifiers (e.g., "N34W084") | `["N34W084", "N44E018", "N44E017", "N43E018"]` |
| `usgs_enabled` | Enable USGS topo maps downloads | `true` |
| `usgs_topo_regions` | List of USGS topo map identifiers | `[{"name": "georgia"}]` |
| `usgs_topo_scales` | List of USGS map scales | `["250k", "100k", "24k"]` |
| `noaa_enabled` | Enable NOAA nautical charts downloads | `true` |
| `noaa_charts_regions` | List of NOAA chart identifiers | `[{"name": "US3EC03M"}]` |
| `noaa_chart_types` | List of NOAA chart types | `["ENC", "RNC"]` |

### GPS Configuration

| Variable Name | Description | Default Value |
|---------------|-------------|---------------|
| `gpsd_enabled` | Enable GPS daemon service | `false` |
| `gpsd_device` | GPS device path | `/dev/ttyUSB0` |

See `defaults/main.yml` for complete variable documentation and examples.

## Dependencies

None

## Example Playbooks

### Basic Installation

```yaml
---
- name: Install geospatial software and download maps
  hosts: workstations
  become: true
  roles:
    - role: brcak_zmaj.almir_ansible.geospatial_data
  vars:
    user: "almir"
    install_qgis: true
    install_marble: true
    install_viking: true
```

### Custom Map Regions

```yaml
---
- name: Install geospatial tools with custom map regions
  hosts: workstations
  become: true
  roles:
    - role: brcak_zmaj.almir_ansible.geospatial_data
  vars:
    user: "almir"
    osm_regions:
      - "north-america"
      - "europe"
    srtm_regions:
      - "N34W084"  # Georgia, USA
      - "N35W085"  # Tennessee, USA
    aster_regions:
      - "N34W084"
      - "N35W085"
```

### GPS Hardware Configuration

```yaml
---
- name: Install geospatial tools with GPS support
  hosts: workstations
  become: true
  roles:
    - role: brcak_zmaj.almir_ansible.geospatial_data
  vars:
    user: "almir"
    install_gps_support: true
    gpsd_enabled: true
    gpsd_device: "/dev/ttyACM0"
```

## Map Data Organization

Map data is organized in separate directories under `{{ map_data_dir }}`:

- `{{ map_data_dir }}/osm/` - OpenStreetMap PBF files
- `{{ map_data_dir }}/mbtiles/` - MBTiles format files
- `{{ map_data_dir }}/srtm/` - SRTM elevation data
- `{{ map_data_dir }}/aster/` - ASTER elevation data
- `{{ map_data_dir }}/usgs/` - USGS topographic maps
- `{{ map_data_dir }}/noaa/` - NOAA nautical charts

Each map type uses different file formats and serves different purposes, so they are kept in separate directories to avoid conflicts.

## Tile Identifier Format

For SRTM and ASTER elevation data, tile identifiers use the format:
- **Format**: `N/S[latitude]E/W[longitude]`
- **Example**: `N34W084` = 34°N, 84°W (Georgia, USA)
- **Example**: `N44E018` = 44°N, 18°E (Bosnia-Herzegovina)

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
