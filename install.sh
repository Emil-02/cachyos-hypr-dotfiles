#!/usr/bin/env bash
# Pasang dotfiles ini ke $HOME. Semua file yang akan ditimpa dicadangkan dulu,
# dan bisa dikembalikan dengan ./uninstall.sh.
#
#   ./install.sh                 pasang & terapkan mode Noctalia
#   ./install.sh --mode end4     terapkan mode lain (noctalia|caelestia|end4|sekaipop)
#   ./install.sh --deps          pasang juga paket untuk mode yang dipilih
#   ./install.sh --no-apply      hanya pasang skrip & mode, tanpa mengubah tampilan aktif
#   ./install.sh --dry-run       tampilkan rencana tanpa mengubah apa pun
set -euo pipefail

REPO="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/common.sh
source "$REPO/lib/common.sh"
load_mode_files "$REPO/bin/ganti-mode"

MODE=noctalia DEPS=0 DRY=0 APPLY=1 YES=0
while [ $# -gt 0 ]; do
  case "$1" in
    --mode) MODE="${2:?--mode butuh nilai}"; shift ;;
    --mode=*) MODE="${1#*=}" ;;
    --deps) DEPS=1 ;;
    --dry-run) DRY=1 ;;
    --no-apply) APPLY=0 ;;
    -y|--yes) YES=1 ;;
    -h|--help) sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Opsi tidak dikenal: $1" >&2; exit 1 ;;
  esac
  shift
done

info() { printf '\033[1;36m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31m[x]\033[0m %s\n' "$*" >&2; exit 1; }
run()  { if [ $DRY = 1 ]; then echo "  (dry-run) $*"; else "$@"; fi; }

[[ " ${MODES[*]} " == *" $MODE "* ]] || die "Mode tidak dikenal: $MODE (pilih: ${MODES[*]})"
[ "$(id -u)" -ne 0 ] || die "Jangan jalankan sebagai root."
for c in rsync tar zstd sed grep; do command -v "$c" >/dev/null || die "Butuh perintah: $c"; done
command -v pacman >/dev/null || warn "pacman tidak ditemukan: repo ini dibuat untuk CachyOS/Arch."

# ---------- Paket ----------
if [ $DEPS = 1 ]; then
  info "Memasang paket dasar (packages/base.txt)"
  mapfile -t pkgs < <(grep -vE '^\s*(#|$)' "$REPO/packages/base.txt")
  helper=$(command -v paru || command -v yay || true)
  if [ -n "$helper" ]; then run "$helper" -S --needed "${pkgs[@]}"
  else run sudo pacman -S --needed "${pkgs[@]}"; fi
  if [ "$MODE" != noctalia ]; then
    info "Memasang shell untuk mode $MODE"
    run "$REPO/scripts/install-mode-$MODE.sh"
  fi
fi

# ---------- Daftar target (relatif ke $HOME) ----------
TARGETS=()
for s in "${BIN_SCRIPTS[@]}"; do TARGETS+=(".local/bin/$s"); done
for m in "${MODES[@]}"; do TARGETS+=(".local/share/mode-tampilan/$m"); done
for p in "${SHELL_FILES[@]}"; do [ -e "$REPO/shell/$p" ] && TARGETS+=("$p"); done
# Dibuat oleh caelestia-overlay di bawah
TARGETS+=(.config/quickshell/caelestia .local/state/caelestia-overlay.stamp)
if [ $APPLY = 1 ]; then
  for p in "${MODE_FILES[@]}"; do TARGETS+=("$p"); done
  TARGETS+=(.local/state/mode-tampilan/mode)
fi

# ---------- Cadangan ----------
TS=$(date +%Y%m%d_%H%M%S_%3N)
BK="$HOME/.local/share/hypr-dotfiles/backups/$TS"
existing=()
for p in "${TARGETS[@]}"; do
  if [ -e "$HOME/$p" ] || [ -L "$HOME/$p" ]; then existing+=("$p"); fi
done
info "Rencana: ${#TARGETS[@]} target, ${#existing[@]} sudah ada dan akan dicadangkan ke $BK"
if [ $DRY = 1 ]; then printf '  %s\n' "${TARGETS[@]}"; exit 0; fi
if [ $YES = 0 ]; then
  read -rp "Lanjutkan? [y/N] " ans
  [[ "$ans" =~ ^[yY]$ ]] || { echo "Dibatalkan."; exit 0; }
fi

mkdir -p "$BK"
printf '%s\n' "${TARGETS[@]}" > "$BK/targets.txt"
if [ ${#existing[@]} -gt 0 ]; then
  tar --zstd -C "$HOME" -cpf "$BK/backup.tar.zst" "${existing[@]}"
fi
info "Cadangan tersimpan: $BK"

# ---------- Pasang ----------
render() { # ganti @HOME@ dengan $HOME di semua file teks di bawah path yang diberikan
  local esc
  esc=$(printf '%s' "$HOME" | sed 's/[&|\\]/\\&/g')
  grep -rlIF -- '@HOME@' "$@" 2>/dev/null | while read -r f; do sed -i "s|@HOME@|$esc|g" "$f"; done || true
}
place() { # place <src> <relpath-di-HOME>
  local src="$1" dst="$HOME/$2"
  if [ -d "$src" ]; then
    # Folder ditukar sekaligus agar Hyprland tidak memuat config setengah jadi.
    local tmp="$dst.baru.$$"
    rm -rf "$tmp"
    mkdir -p "$(dirname "$dst")"
    cp -a "$src" "$tmp"
    render "$tmp"
    rm -rf "$dst"
    mv "$tmp" "$dst"
    return
  else
    rm -rf "$dst"
    mkdir -p "$(dirname "$dst")"
    cp -a "$src" "$dst"
  fi
  render "$dst"
}

info "Memasang skrip ke ~/.local/bin"
for s in "${BIN_SCRIPTS[@]}"; do place "$REPO/bin/$s" ".local/bin/$s"; chmod +x "$HOME/.local/bin/$s"; done

info "Memasang mode tampilan ke ~/.local/share/mode-tampilan"
for m in "${MODES[@]}"; do place "$REPO/modes/$m" ".local/share/mode-tampilan/$m"; done

info "Memasang konfigurasi shell"
for p in "${SHELL_FILES[@]}"; do
  if [ -e "$REPO/shell/$p" ]; then place "$REPO/shell/$p" "$p"; fi
done

if [ $APPLY = 1 ]; then
  info "Menerapkan mode $MODE"
  tree="$HOME/.local/share/mode-tampilan/$MODE"
  for p in "${MODE_FILES[@]}"; do
    if [ -e "$tree/$p" ] || [ -L "$tree/$p" ]; then
      place "$tree/$p" "$p"
    fi
  done
  if [ -f "$tree/gsettings.txt" ] && command -v gsettings >/dev/null; then
    while read -r k v; do gsettings set org.gnome.desktop.interface "$k" "$v" 2>/dev/null || true; done < "$tree/gsettings.txt"
  fi
  mkdir -p "$HOME/.local/state/mode-tampilan"
  echo "$MODE" > "$HOME/.local/state/mode-tampilan/mode"
fi

systemctl --user daemon-reload 2>/dev/null || true
[ -d "$HOME/.local/share/caelestia-custom" ] && "$HOME/.local/bin/caelestia-overlay" >/dev/null 2>&1 || true

case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) warn "Tambahkan ~/.local/bin ke PATH." ;; esac

if [ $APPLY = 1 ] && [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
  info "Menyalakan shell mode $MODE"
  "$HOME/.local/bin/ganti-mode" "$MODE" || warn "Mode $MODE belum siap. Jalankan: ./scripts/install-mode-$MODE.sh"
fi

info "Selesai. Ganti mode kapan saja dengan: ganti-mode (menu) atau SUPER+F12"
echo "    Untuk membatalkan: $REPO/uninstall.sh"
