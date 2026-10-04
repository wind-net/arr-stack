# Podman Quadlets

Podman Quadlet container configurations for media stack and services:

## Services Included

### Media Stack
- **jellyfin** - Jellyfin Media Server
- **sonarr** - TV episode automation
- **radarr** - Movie automation  
- **lidarr** - Music automation
- **prowlarr** - Indexer manager
- **jellyseerr** - Request manager
- **navidrome** - Music streaming
- **qbittorrent** - Torrent client (routed via Gluetun VPN)
- **tdarr** - Video transcoding/automation server
- **tdarr-node** - Tdarr worker node

### Tools & Services
- **gluetun** - VPN client (Wireguard/AirVPN)
- **homarr** - Dashboard
- **wizarr** - Jellyfin invite manager
- **flaresolverr** - Cloudflare challenge solver
- **trilium** - Personal knowledge base
- **aurral-backend** - Artist request manager backend
- **aurral-frontend** - Artist request manager UI

## Usage

Copy `.container` files to:
```bash
# User-level (default)
~/.config/containers/systemd/

# System-wide (requires sudo)
/etc/containers/systemd/
```

Then enable and start:
```bash
systemctl --user daemon-reload
systemctl --user enable *.service
systemctl --user start *.service
```

## Network

All services are configured for `mynet.network` which must be pre-created:
```bash
podman network create mynet
```

## Features

- ✅ Health checks removed (for stability)
- ✅ Auto-update enabled (registry)
- ✅ Restart policies configured
- ✅ Resource limits set
- ✅ Persistent volumes with proper permissions
- ✅ SELinux labels configured
