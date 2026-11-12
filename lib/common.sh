# Daftar bersama untuk sync.sh, install.sh, dan uninstall.sh.
# shellcheck shell=bash disable=SC2034

MODES=(noctalia caelestia end4 sekaipop)
GSET_KEYS=(gtk-theme icon-theme cursor-theme cursor-size font-name color-scheme)

# Skrip milik repo ini yang dipasang ke ~/.local/bin
BIN_SCRIPTS=(
  ganti-mode simpan-tampilan wallpaper-acak buat-wallpaper-hidup
  caelestia-overlay caelestia-wallpaper-cycle
  noctalia-auto-mode noctalia-greeting sekai-fetch
)

# Konfigurasi shell yang sama untuk semua mode (relatif ke $HOME)
SHELL_FILES=(
  .config/noctalia
  .local/state/noctalia/settings.toml
  .config/caelestia
  .local/share/caelestia-custom
  .config/sekaipop
  .config/illogical-impulse/config.json
  .config/quickshell/ii-lyrics
  .config/systemd/user/noctalia-greeting.service
  .config/systemd/user/noctalia-greeting.timer
)

# File yang berbeda per mode diambil langsung dari array FILES di ganti-mode,
# supaya daftar ini tidak pernah berbeda dengan yang dipakai saat berganti mode.
load_mode_files() { # load_mode_files <path-ganti-mode>
  mapfile -t MODE_FILES < <(
    sed -n '/^FILES=(/,/^)/p' "$1" | sed '1d;$d' \
      | sed 's/#.*//; s/^[[:space:]]*//; s/[[:space:]]*$//' | grep -v '^$'
  )
  [ "${#MODE_FILES[@]}" -gt 0 ] || { echo "Gagal membaca daftar FILES dari $1" >&2; return 1; }
}
