# ARR‑Stack using Podman Quadlets

## Overview
This repository provides a **rootless Podman‑quadlet** setup for the popular ARR suite (Radarr, Sonarr, Readarr, Plex) and a Caddy reverse‑proxy. All container data is stored under a single host directory `/data/arr` making backups and migrations straightforward.

## Folder structure
```
/data/arr
├── config        # Configuration files for each service
│   ├── radarr
│   ├── sonarr
│   ├── seerr
│   ├── readarr
│   ├── plex
│   ├── qbittorrent
│   └── caddy   
├── media         # TV, movies, books,
│   ├── tv
│   ├── movies
│   ├── music
│   └── books
├── downloads
└── tmp # Temporary download folders for each service
    ├── radarr
    ├── sonarr
    ├── readarr
    ├── plex-transcode
└── ...
```

- **`systemd/`** – Contains Podman quadlet files (`*.container` and `arr.network`). These are standard systemd unit files that can be started with `systemctl --user`. They define the container image, environment, volume mounts, ports and resource limits.
- **`config/`** – Holds the Caddy configuration (`caddyfile`) that proxies the services under `media.wlankabel.ch`.

## Quick start guide
1. **Create the host directories**
   ```bash
       sudo mkdir -p /data/arr/config/{radarr,sonarr,readarr,plex,caddy,qbittorrent}
       sudo mkdir -p /data/arr/data/{media/{tv,movies,books},downloads/{radarr,sonarr,readarr},tmp/{radarr,sonarr,readarr}}
   sudo chown -R $(id -u):$(id -g) /data/arr
   ```
2. **Copy the quadlet files** (already in `systemd/`).
3. **Reload systemd and enable services**
   ```bash
   systemctl --user daemon-reload
       for svc in radarr sonarr readarr plex caddy qbittorrent; do
       systemctl --user enable --now ${svc}.service
   done
   ```
4. **Configure Caddy** – Edit `config/caddyfile` if you need custom domains or TLS settings, then restart the Caddy service:
   ```bash
   systemctl --user restart caddy.service
   ```
5. **Access the services**
   - Radarr: `http://media.wlankabel.ch/radarr`
   - Sonarr: `http://media.wlankabel.ch/sonarr`
   - Readarr: `http://media.wlankabel.ch/readarr`
   - Plex: `http://media.wlankabel.ch/plex`

## Resource limits (optional)
If you want to restrict CPU and memory per container, add `--cpus` and `--memory` options to the `PublishPort` lines in each `.container` file, e.g.:
```ini
PublishPort=7878:7878
# Add resource limits
CPUQuota=200%   # 2 CPUs
Memory=2G
```
(Adjust according to your hardware.)

## Notes
- All containers run as rootless with `PUID=0` and `PGID=0`. Change these if you prefer a non‑root user.
- `AutoUpdate=registry` ensures containers pull the latest image on restart.
- Health checks are defined for each service to allow systemd to restart unhealthy containers automatically.

For more detailed examples, see the `example-quadlets/` directory.
