#!/usr/bin/env bash
# Salin konfigurasi dari sistem ini ke dalam repo (kebalikan dari install.sh).
# Jalankan setiap kali tampilan diubah, lalu commit hasilnya.
#   ./sync.sh            sinkronkan semua
#   ./sync.sh --check    hanya tampilkan perbedaan, tanpa menyalin
set -euo pipefail

REPO="$(cd "$(dirname "$0")" && pwd)"
TREES="${MODE_TREES:-$HOME/.local/share/mode-tampilan}"
STATE_DIR="$HOME/.local/state/mode-tampilan"
CHECK=0
[ "${1:-}" = --check ] && CHECK=1

# shellcheck source=lib/common.sh
source "$REPO/lib/common.sh"
load_mode_files "$HOME/.local/bin/ganti-mode"

# Pola yang tidak pernah ikut ke repo (state mesin, cadangan, cache, gambar pribadi)
EXCLUDES=(
  --delete-excluded --exclude=Koi.png
  --exclude=fish_variables --exclude='*.bak' --exclude='*.save' --exclude='*.backup'
  --exclude='*.sebelum-*' --exclude=installed_listfile --exclude=__pycache__
  --exclude=node_modules --exclude=.venv
)

copy_into() { # copy_into <src> <dst>
  local src="$1" dst="$2"
  if [ $CHECK = 1 ]; then
    [ -e "$dst" ] || { echo "  + ${dst#"$REPO"/}"; return; }
    rsync -a --delete --dry-run --itemize-changes "${EXCLUDES[@]}" "$src" "$dst" | sed 's/^/  /'
  else
    mkdir -p "$(dirname "$dst")"
    rsync -a --delete "${EXCLUDES[@]}" "$src" "$dst"
  fi
}

copy_path() { # copy_path <src-root> <relpath> <dst-root>
  if [ -d "$1/$2" ] && [ ! -L "$1/$2" ]; then copy_into "$1/$2/" "$3/$2/"
  elif [ -e "$1/$2" ] || [ -L "$1/$2" ]; then copy_into "$1/$2" "$3/$2"
  fi
}

echo "==> Skrip (bin/)"
for s in "${BIN_SCRIPTS[@]}"; do
  copy_path "$HOME/.local/bin" "$s" "$REPO/bin"
done

echo "==> Mode tampilan (modes/)"
current="$(cat "$STATE_DIR/mode" 2>/dev/null || echo noctalia)"
for m in "${MODES[@]}"; do
  dst="$REPO/modes/$m"
  if [ "$m" = "$current" ]; then
    # Mode aktif tinggal di $HOME, bukan di folder mode-tampilan.
    echo "  $m (aktif, diambil dari \$HOME)"
    for p in "${MODE_FILES[@]}"; do
      if [ -e "$HOME/$p" ] || [ -L "$HOME/$p" ]; then
        copy_path "$HOME" "$p" "$dst"
      elif [ $CHECK = 0 ]; then
        rm -rf "${dst:?}/$p"
      fi
    done
    if [ $CHECK = 0 ]; then
      : > "$dst/gsettings.txt"
      for k in "${GSET_KEYS[@]}"; do
        echo "$k $(gsettings get org.gnome.desktop.interface "$k" 2>/dev/null)" >> "$dst/gsettings.txt"
      done
    fi
  elif [ -d "$TREES/$m" ]; then
    echo "  $m"
    copy_into "$TREES/$m/" "$dst/"
  else
    echo "  $m (dilewati: belum direkam di $TREES)"
  fi
done

echo "==> Konfigurasi shell (shell/)"
for p in "${SHELL_FILES[@]}"; do
  copy_path "$HOME" "$p" "$REPO/shell"
done

[ $CHECK = 1 ] && exit 0

echo "==> Mengganti path pribadi dengan @HOME@"
grep -rlIF -- "$HOME" "$REPO/bin" "$REPO/modes" "$REPO/shell" 2>/dev/null | while read -r f; do
  sed -i "s|$HOME|@HOME@|g" "$f"
done

echo "==> Memeriksa kemungkinan rahasia"
if grep -rnIE '(ghp_[A-Za-z0-9]{20,}|gho_[A-Za-z0-9]{20,}|sk-[A-Za-z0-9]{20,}|AIza[0-9A-Za-z_-]{30,}|xox[baprs]-[A-Za-z0-9-]{10,}|-----BEGIN [A-Z ]*PRIVATE KEY)' \
     "$REPO/bin" "$REPO/modes" "$REPO/shell"; then
  echo "PERINGATAN: ada pola yang mirip token/kunci di atas. Periksa sebelum commit!" >&2
  exit 1
fi
echo "Selesai. Cek dengan: git -C \"$REPO\" status"
