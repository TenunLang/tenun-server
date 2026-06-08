#!/usr/bin/env bash
# Installer Tenun untuk server Linux (binary + CLI tenun-server).
#   curl -fsSL https://raw.githubusercontent.com/TenunLang/tenun-server/main/install.sh | sudo bash
set -euo pipefail

REPO="TenunLang/Tenun"                 # repo binary tenun
SREPO="TenunLang/tenun-server"         # repo tooling ini
BIN=/usr/local/bin/tenun
CLI=/usr/local/bin/tenun-server

need_root() { [ "$(id -u)" = "0" ] || { echo "Jalankan sebagai root (sudo)."; exit 1; }; }
need_root

arch=$(uname -m)
case "$arch" in
  x86_64|amd64) A="x86_64" ;;
  aarch64|arm64) A="aarch64" ;;
  *) echo "Arsitektur $arch belum didukung"; exit 1 ;;
esac

echo "[1/3] Unduh binary tenun ($A)..."
URL="https://github.com/$REPO/releases/latest/download/tenun-linux-$A"
if curl -fsSL "$URL" -o "$BIN" 2>/dev/null; then
  chmod +x "$BIN"
  echo "      terpasang: $BIN"
else
  echo "      WARNING: gagal unduh rilis ($URL)."
  echo "      Build dari sumber: git clone https://github.com/$REPO && cd Tenun && zig build -Doptimize=ReleaseFast"
  echo "      lalu salin zig-out/bin/tenun ke $BIN"
fi

echo "[2/3] Pasang CLI tenun-server..."
curl -fsSL "https://raw.githubusercontent.com/$SREPO/main/bin/tenun-server" -o "$CLI"
chmod +x "$CLI"
echo "      terpasang: $CLI"

echo "[3/3] Selesai."
echo
echo "Pakai:"
echo "  1) Buat domain di aaPanel (root: /www/wwwroot/<domain>) + pasang SSL bila perlu."
echo "  2) Taruh aplikasi Tenun di /www/wwwroot/<domain> (entry default index.tenun)."
echo "  3) tenun-server new <domain>                 # port otomatis + reverse proxy nginx + systemd"
echo "     tenun-server new <domain> --entry app.tenun   # entry custom (bukan index.tenun)"
echo "  4) buka https://<domain>"
echo
echo "Copot semua: tenun-server uninstall"
