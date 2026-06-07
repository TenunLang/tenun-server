# tenun-server

Installer & deploy tool **aplikasi Tenun di server Linux** + integrasi **nginx (aaPanel)**. Reverse-proxy domain → app Tenun (HTTP **dan** WebSocket), service via **systemd**.

## Pasang

```
curl -fsSL https://raw.githubusercontent.com/TenunLang/tenun-server/main/install.sh | sudo bash
```

Memasang binary `tenun` ke `/usr/local/bin/tenun` + CLI `tenun-server`.

## Alur deploy (aaPanel)

1. **Buat domain di aaPanel** seperti biasa (root `/www/wwwroot/<domain>`), pasang SSL kalau perlu (Let's Encrypt). Ini bikin vhost + cert + well-known.
2. **Taruh aplikasi Tenun** di `/www/wwwroot/<domain>` (ada `index.tenun`). Pasang dependensi: `cd /www/wwwroot/<domain> && tenun add jala`.
3. **Sambungkan ke Tenun:**

```
tenun-server new wa-rs.imtaqin.id
```

Otomatis:
- Pilih port (mis. `127.0.0.1:8xxx`) — bisa override `--port`.
- Bikin **systemd service** `tenun-<domain>` (`TENUN_WORKERS=1`, `TENUN_PORT=<port>`, `WorkingDirectory` = folder app) → auto-start & restart.
- **Tulis ulang vhost** `/www/server/panel/vhost/nginx/<domain>.conf` jadi reverse-proxy ke app (HTTP + WebSocket), **mempertahankan SSL cert aaPanel** + blok `well-known` (perpanjangan cert tetap jalan). Vhost lama di-backup `*.tenun.bak.*`.
- `nginx -t` lalu reload.

4. Buka `https://<domain>`.

## Perintah

```
tenun-server new <domain> [--dir DIR] [--port PORT] [--user USER]
tenun-server rm <domain>          # hentikan service + pulihkan vhost lama (backup) / hapus
tenun-server list                 # daftar app Tenun
tenun-server restart|stop|start|status <domain>
tenun-server logs <domain>        # journalctl -f
tenun-server install              # perbarui binary tenun
```

## Cara kerja WebSocket

App Tenun (kerangka Jala) melayani **HTTP + WebSocket di port yang sama**. Vhost memforward header `Upgrade`/`Connection` sehingga live chat jalan lewat domain (`wss://<domain>`), satu proses. Tidak perlu port terpisah.

## Multi-aplikasi

Tiap domain = port sendiri (`TENUN_PORT`) + service systemd sendiri. Jalankan `tenun-server new` untuk tiap domain. Skala lebih besar: jalankan beberapa service per app + load balancing di nginx `upstream`, state bersama di Redis/Postgres.

## Detail teknis

- Binary `tenun` statis (musl) — tanpa dependensi sistem.
- Port app diatur via env `TENUN_PORT` (didukung runtime Tenun), jadi app tak perlu ubah kode.
- Worker `TENUN_WORKERS=1` per proses (koneksi DB/Redis per-proses); skalakan dengan menambah service + `upstream`.
- Contoh vhost & unit ada di `templates/`.

## Lisensi

MIT.
