# Plex behind Traefik with WUD (Boilerplate)

This boilerplate sets up **Plex** using the `linuxserver/plex` Docker image, running behind **Traefik**, with optional **WUD** support for update monitoring.

---

## 🧩 Features

- Plex via linuxserver.io Docker image  
- Reverse proxy handled by Traefik (HTTPS, routing, certificates)
- Optional WUD support for update notifications or automation
- `.env`-based configuration for easy re-use and portability

---

## 📦 Requirements

Before using this template, make sure you have:

- Docker & Docker Compose installed
- A working Traefik setup (with ACME enabled if using HTTPS)
- A DNS record pointing to your server
- Optionally: WUD running in your environment

---

## ⚙️ Configuration

### 1️⃣ Edit `.env`

Set your variables:

```
DOMAIN=example.com
SUBDOMAIN=plex
TZ=Europe/Copenhagen
PUID=1000
PGID=1000
```

Adjust to match your user and timezone.

---

### 2️⃣ Modify the `docker-compose.yml`

You may need to update:

- volume paths
- network names
- Plex claims if needed
- Setup RAM transcoding
    Create transcoding directory
        sudo mkdir /opt/plex/tmp
    Setup the system to mount the RAM disk on every boot
        sudo nano /etc/fstab
        Append the following line:
        tmpfs    /opt/plex/tmp    tmpfs    defaults,noatime,nosuid,nodev,noexec,size=64G,mode=1777    0    0
    Grant writing permissions for the transcoding directory
        sudo chown -R plex:plex /tmp/transcoding
    Use /tmp/transcoding in Plex Media Server > Settings > Server > Transcoder > Temporary directory


Reference:  
👉 https://docs.linuxserver.io/images/docker-plex/

---

## 🚀 Deployment

Run the stack:

```bash
docker compose up -d
```

If everything is configured correctly, Plex will be available at:

```
https://plex.example.com
```

(via Traefik)

---

## 🔄 Updates (Optional)

If using **WUD**, ensure the container name/image match your WUD config.

WUD will detect new images and notify or auto-update depending on your setup.

---

## 📁 Notes

This template is designed as a **boilerplate** — meaning you should adjust networking, container naming, volumes, and metadata to match your environment.
