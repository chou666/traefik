# Traefik HTTPS Setup — Local Development

Generate a self-signed certificate for https in development.

This will generate ca, server certs and start traefik on [traefik.127.0.0.1.nip.io](traefik.127.0.0.1.nip.io)

## Prerequisites

- Docker & Docker Compose
- `mkcert` installed on your machine

---

## 1. Install mkcert

```bash
# Install certutil (required for Firefox support)
sudo apt install libnss3-tools

# Download and install mkcert
curl -Lo mkcert https://github.com/FiloSottile/mkcert/releases/latest/download/mkcert-v1.4.4-linux-amd64
chmod +x mkcert && sudo mv mkcert /usr/local/bin/

# Install the local CA into the system and Firefox
# Make sure Firefox is CLOSED before running this
mkcert -install
```

> ⚠️ Firefox must be fully closed when running `mkcert -install`, otherwise the CA won't be registered.

---

## 2. Generate Certificates

Generate a wildcard certificate for all *.127.0.0.1.nip.io subdomains
```bash
make genereate-cert
```
## 4. Project Structure

```
traefik-https/
├── config/
│   ├── nip/
│   │   ├── local.pem           # mkcert certificate
│   │   ├── local-key.pem       # mkcert private key
│   │   └── tls.toml            # Traefik dynamic TLS config
│   └── traefik.toml            # Traefik static config (optional)
├── docker-compose.yml
└── README.md
```

---

## Start Traefik

```bash
# Create the external network if it doesn't exist yet
docker network create reverse-proxy

# Start Traefik
docker compose up -d

# Check logs
docker compose logs -f https
```

---

## 6. Verify

Open Firefox and navigate to any `*.127.0.0.1.nip.io` subdomain over HTTPS.  
The connection should be trusted with no security warning. 🎉

To verify the certificate is loaded correctly:

```bash
docker compose logs https | grep -i "tls\|cert"
```

---

## Troubleshooting

| Error | Cause | Fix |
|---|---|---|
| `MOZILLA_PKIX_ERROR_SELF_SIGNED_CERT` | mkcert CA not registered in Firefox | Close Firefox, run `mkcert -install`, reopen Firefox |
| `SEC_ERROR_UNKNOWN_ISSUER` | Wrong certificate loaded | Check paths in `tls.toml` |
| `PR_END_OF_FILE_ERROR` | Traefik not loading the cert | Check `docker compose logs`, verify `tls.toml` is in `/etc/traefik/nip/` |
| `TRAEFIK DEFAULT CERT` shown | `tls.toml` not read by Traefik | Verify `--providers.file.directory` points to the correct folder |
# Install



## Command
`make start`

## Monitoring

https://traefik.127.0.0.1.nip.io/dashboard/