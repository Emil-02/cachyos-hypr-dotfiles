#!/usr/bin/env bash
# Pasang shell SekaiPop untuk mode "Imut". Memakai install-deps.sh dari upstream
# (paket, font, service) lalu menyalin folder shell-nya saja; config Hyprland dari repo ini.
set -euo pipefail
SP_REPO=https://github.com/Blapples/SekaiPop
SP_REF="${SP_REF:-a9155b43884e8f748474c5ec050665ff28178800}"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

echo "==> 1/3 Mengambil SekaiPop @ ${SP_REF:0:7}"
git clone --filter=blob:none --quiet "$SP_REPO" "$TMP/sp"
git -C "$TMP/sp" checkout --quiet "$SP_REF"

echo "==> 2/3 Memasang dependensi (install-deps.sh upstream)"
(cd "$TMP/sp" && ./install-deps.sh)
sudo pacman -S --needed gvfs easyeffects zenity blueman ffmpegthumbs hypridle

echo "==> 3/3 Memasang shell ke ~/.config/quickshell/sekaipop"
mkdir -p "$HOME/.config/quickshell"
rm -rf "$HOME/.config/quickshell/sekaipop"
cp -a "$TMP/sp/sekaipop" "$HOME/.config/quickshell/sekaipop"
printf 'commit=%s\nrepo=%s\nref=main\n' "$SP_REF" "$SP_REPO" > "$HOME/.config/quickshell/sekaipop/.source"

echo "Selesai. Pindah ke mode ini dengan: ganti-mode sekaipop"
