# Ansible Host Setup for ARR Stack

This playbook prepares a fresh Linux host for the rootless Podman quadlet deployment.

## What it does

| Component | Action |
|-----------|--------|
| **User** | Creates `arr` user (UID 1000), adds to `video` group (Plex HW transcoding) |
| **Lingering** | Enables `loginctl enable-linger arr` for systemd user services on boot |
| **Directories** | Creates full `/data/arr` tree with correct ownership |
| **Gluetun env** | Creates `/data/arr/config/gluetun/gluetun.env` template (fill in your ProtonVPN key) |
| **Sysctl** | Sets `net.ipv4.ip_unprivileged_port_start=0` (allows rootless Caddy on 80/443) |
| **Firewalld** | Opens 80/443 (TCP+UDP) in public zone |
| **Certbot** | Requests Let's Encrypt certs for configured domains, deploys to Caddy config |
| **Quadlets** | Copies `systemd/*.container` + `arr.pod` to `~/.config/containers/systemd/` |
| **Services** | Reloads systemd, starts `arr-pod` + `gluetun` first, enables all services |

## Prerequisites

- Target host: **Rocky Linux / RHEL / Fedora** (dnf-based)
- SSH access as root (or user with passwordless sudo)
- Ansible installed on control machine
- Domain DNS pointing to server IP

## Usage

### 1. Edit inventory

```bash
cd ansible
cp inventory.yml inventory.yml.local
# Edit inventory.yml.local with your server IP, domains, email
```

### 2. Run playbook

```bash
ansible-playbook -i inventory.yml.local setup-host.yml --ask-become-pass
```

Or with SSH key:

```bash
ansible-playbook -i inventory.yml.local setup-host.yml
```

### 3. After playbook completes

1. **Edit Gluetun credentials**:
   ```bash
   ssh arr@your.server
   vim /data/arr/config/gluetun/gluetun.env
   # Add your WIREGUARD_PRIVATE_KEY from ProtonVPN
   ```

2. **Start services** (if not already started):
   ```bash
   systemctl --user start arr-pod.service gluetun.service
   journalctl --user -u gluetun.service -f  # wait for "healthy"
   for svc in radarr sonarr lidarr prowlarr bazarr seerr qbittorrent plex caddy; do
       systemctl --user start ${svc}.service
   done
   ```

3. **Configure qBittorrent** (Web UI → Options → Web UI → Authentication → "Bypass authentication for localhost")

4. **Verify**:
   - `https://media.wlankabel.ch/radarr`
   - `https://plex.wlankabel.ch`
   - `https://seerr.wlankabel.ch`

## Customization

### Skip certbot (use your own certs)

```yaml
# In inventory or --extra-vars
certbot_enabled: false
```

### Different user/UID

```yaml
arr_user: "media"
arr_uid: 2000
arr_gid: 2000
```

### Different data path

```yaml
data_root: "/mnt/media/arr"
```

### Additional firewall ports

```yaml
firewall_allowed_ports:
  - "80/tcp"
  - "443/tcp"
  - "443/udp"
  - "32400/tcp"   # Plex direct access (if not via Caddy)
```

## Files deployed

```
/home/arr/.config/containers/systemd/
├── arr.pod
├── gluetun.container
├── radarr.container
├── sonarr.container
├── lidarr.container
├── prowlarr.container
├── bazarr.container
├── seerr.container
├── qbittorrent.container
├── plex.container
└── caddy.container

/data/arr/
├── config/
│   ├── gluetun/gluetun.env
│   └── caddy/
│       ├── caddyfile
│       └── certs/ (populated by certbot)
├── media/...
├── downloads/...
└── tmp/...

/etc/letsencrypt/secrets/cloudflare.ini  # Cloudflare API token (fill in)
```

## Certbot (Cloudflare DNS challenge)

The playbook uses `certbot-dns-cloudflare` for DNS-01 validation (no need to open port 80/443 for validation).

1. **Create Cloudflare API token** at https://dash.cloudflare.com/profile/api-tokens with permissions:
   - Zone → DNS → Read
   - Zone → DNS → Edit
   - Zone Resources → Include → Specific zone → your domain

2. **Edit the credentials file** after playbook runs:
   ```bash
   vim /etc/letsencrypt/secrets/cloudflare.ini
   # Add: dns_cloudflare_api_token = "your_token_here"
   ```

3. **Re-run certbot task** (or run manually):
   ```bash
   ansible-playbook -i inventory.yml.local setup-host.yml --tags certbot
   ```

Certbot's systemd timer (`certbot-renew.timer`) handles automatic renewal. The playbook copies renewed certs to Caddy's config directory and restarts Caddy.

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `systemctl --user` fails | Ensure `loginctl enable-linger arr` ran; re-login as arr |
| Caddy can't bind 80/443 | Verify `sysctl net.ipv4.ip_unprivileged_port_start=0` |
| Gluetun not healthy | Check `/data/arr/config/gluetun/gluetun.env` has correct WireGuard key |
| qBittorrent port forward 403 | Enable "Bypass authentication for localhost" in qBittorrent Web UI |
| Plex no HW transcode | Ensure `arr` user in `video` group; re-login; check `/dev/dri/renderD128` exists |

## Idempotency

Safe to re-run. Will not overwrite existing `gluetun.env` (force: false), only creates missing directories, and only requests certs if not already valid.