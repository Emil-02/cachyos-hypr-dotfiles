#!/usr/bin/env bash
# Pasang shell Caelestia untuk mode "Santai". Config-nya sudah ada di repo ini,
# jadi installer dots bawaan Caelestia TIDAK dijalankan (tidak menimpa ~/.config/hypr).
set -euo pipefail
helper=$(command -v paru || command -v yay) || { echo "Butuh AUR helper (paru/yay)." >&2; exit 1; }

echo "==> Memasang caelestia-shell + caelestia-cli (kompilasi quickshell-git bisa 10-30 menit)"
echo "    Jika ditanya konflik quickshell dengan paket lain, pilih hapus paket lama (y)."
"$helper" -S --needed caelestia-shell caelestia-cli polkit-gnome cliphist

echo "==> Membangun overlay kustomisasi Caelestia"
"$HOME/.local/bin/caelestia-overlay" --paksa || true

echo "Selesai. Pindah ke mode ini dengan: ganti-mode caelestia"
