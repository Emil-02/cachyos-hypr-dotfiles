#!/usr/bin/env bash
# Kembalikan kondisi sebelum ./install.sh dijalankan.
#   ./uninstall.sh                 pulihkan cadangan terbaru
#   ./uninstall.sh <nama-cadangan> pulihkan cadangan tertentu
#   ./uninstall.sh --list          lihat daftar cadangan
set -euo pipefail

ROOT="$HOME/.local/share/hypr-dotfiles/backups"
[ -d "$ROOT" ] || { echo "Belum ada cadangan di $ROOT"; exit 1; }

if [ "${1:-}" = --list ]; then find "$ROOT" -mindepth 1 -maxdepth 1 -printf '%f\n' | sort; exit 0; fi
TS="${1:-$(find "$ROOT" -mindepth 1 -maxdepth 1 -printf '%f\n' | sort | tail -n1)}"
BK="$ROOT/$TS"
[ -f "$BK/targets.txt" ] || { echo "Cadangan tidak valid: $BK"; exit 1; }

echo "Memulihkan cadangan $TS"
read -rp "File yang dipasang oleh install.sh akan dihapus lalu diganti isi cadangan. Lanjutkan? [y/N] " ans
[[ "$ans" =~ ^[yY]$ ]] || { echo "Dibatalkan."; exit 0; }

prune_empty_parents() { # hapus folder induk yang jadi kosong, berhenti di $HOME
  local d
  d=$(dirname "$HOME/$1")
  while [ "$d" != "$HOME" ] && [ "${d#"$HOME"/}" != "$d" ] && rmdir "$d" 2>/dev/null; do
    d=$(dirname "$d")
  done
}

while IFS= read -r p; do
  [ -n "$p" ] && rm -rf "${HOME:?}/$p"
done < "$BK/targets.txt"
while IFS= read -r p; do
  [ -n "$p" ] && prune_empty_parents "$p"
done < "$BK/targets.txt"

if [ -f "$BK/backup.tar.zst" ]; then
  tar --zstd -C "$HOME" -xpf "$BK/backup.tar.zst"
fi

systemctl --user daemon-reload 2>/dev/null || true
[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ] && hyprctl reload >/dev/null 2>&1 || true
echo "Selesai. Logout lalu login lagi agar semua shell kembali seperti semula."
