#!/usr/bin/env bash
# Pasang shell end-4 illogical-impulse (quickshell "ii") untuk mode "Mewah".
# Hanya folder quickshell/ii yang diambil dari upstream; config Hyprland-nya dari repo ini.
set -euo pipefail
END4_REPO=https://github.com/end-4/dots-hyprland
END4_REF="${END4_REF:-2f2a376fdb2ad738bf55f693dd0b474b64bb0ab8}"
SRC="${XDG_CACHE_HOME:-$HOME/.cache}/end4-dots"
helper=$(command -v paru || command -v yay) || { echo "Butuh AUR helper (paru/yay)." >&2; exit 1; }

PKGS=(
  quickshell-git cava pavucontrol-qt wireplumber pipewire-pulse libdbusmenu-gtk3 playerctl
  geoclue brightnessctl ddcutil bc cliphist curl wget ripgrep jq xdg-user-dirs rsync go-yq
  breeze darkly-bin eza fish fontconfig kitty matugen otf-space-grotesk starship
  ttf-jetbrains-mono-nerd ttf-readex-pro ttf-rubik-vf ttf-material-symbols-variable adw-gtk-theme
  hyprsunset wl-clipboard gnome-keyring networkmanager polkit-kde-agent dolphin
  xdg-desktop-portal xdg-desktop-portal-kde xdg-desktop-portal-gtk xdg-desktop-portal-hyprland
  uv gtk4 libadwaita libsoup3 libportal-gtk4 gobject-introspection
  qt6-5compat qt6-imageformats qt6-multimedia qt6-positioning qt6-quicktimeline qt6-sensors
  qt6-svg qt6-tools qt6-translations qt6-virtualkeyboard qt6-wayland kirigami kdialog syntax-highlighting
  hyprshot slurp swappy tesseract tesseract-data-eng wf-recorder upower wtype ydotool
  fuzzel glib2 imagemagick hypridle hyprlock hyprpicker songrec translate-shell wlogout libqalculate
  bibata-cursor-theme-bin
)

echo "==> 1/3 Memasang paket"
"$helper" -S --needed "${PKGS[@]}"

echo "==> 2/3 Mengambil quickshell ii dari $END4_REPO @ ${END4_REF:0:7}"
if [ ! -d "$SRC/.git" ]; then git clone --filter=blob:none "$END4_REPO" "$SRC"; fi
git -C "$SRC" fetch --quiet origin
git -C "$SRC" checkout --quiet "$END4_REF"
mkdir -p "$HOME/.config/quickshell"
rm -rf "$HOME/.config/quickshell/ii"
cp -a "$SRC/dots/.config/quickshell/ii" "$HOME/.config/quickshell/ii"

echo "==> 3/3 Menyiapkan lingkungan Python untuk ii"
VENV="$HOME/.local/state/quickshell/.venv"
mkdir -p "$(dirname "$VENV")"
UV_NO_MODIFY_PATH=1 uv venv --prompt .venv "$VENV" -p 3.12
uv pip install --python "$VENV/bin/python" -r "$SRC/sdata/uv/requirements.txt"

echo "Selesai. Pindah ke mode ini dengan: ganti-mode end4"
