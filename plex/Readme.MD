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
- Plex claim (if needed)  
- optional RAM transcoding setup  

For full configuration options, see the official docs:  
👉 https://docs.linuxserver.io/images/docker-plex/

---

#### 🧠 Optional: Enable RAM Transcoding (`tmpfs`)

If you want Plex to transcode in RAM instead of writing temporary files to disk (recommended if you have enough memory):

---

**1️⃣ Create a directory for transcoding:**

```bash
sudo mkdir -p /opt/plex/tmp
```

---

**2️⃣ Mount it as a RAM disk via `/etc/fstab`:**

```bash
sudo nano /etc/fstab
```

Add this line to the bottom:

```fstab
tmpfs /opt/plex/tmp tmpfs defaults,noatime,nosuid,nodev,noexec,size=64G,mode=1777 0 0
```

> Adjust `size=64G` based on how much RAM you actually want Plex to use.

---

**3️⃣ Set permissions (LinuxServer.io containers typically run as PUID/PGID set in `.env`):**

```bash
sudo chown -R plex:plex /opt/plex/tmp
```

(If you use a different UID/GID, set them accordingly.)

---

**4️⃣ Update Plex transcoder directory:**

Inside Plex:

```
Settings → Server → Transcoder → Temporary Directory
```

Set it to:

```text
/opt/plex/tmp
```

---

RAM transcoding improves performance and avoids SSD wear — especially useful if you host multiple users or transcode 4K content.

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
