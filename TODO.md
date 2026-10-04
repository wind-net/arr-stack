# ToDo for AI-Agents

I've want the following for my ARR-Stack project using podman quadlets (rootless) as a foundation

- [] Each container stores data under /data/arr (READ README.md for more infos)
- [] Each Container has limits for cpu and ram
- [] Each container arr service is available under media.wlankabel.ch/{readarr,sonarr, etc} and exposed through the caddyfile in the config-directory of this project
- [] each container-file is stored in the systemd folder