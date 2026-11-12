<div align="center">

# 🌸 cachyos-hypr-dotfiles

**Empat tampilan desktop Hyprland dalam satu sistem, berpindah dengan satu tombol.**
*Four Hyprland desktop shells on one machine, switched with a single keybind.*

[![CI](https://github.com/Emil-02/cachyos-hypr-dotfiles/actions/workflows/ci.yml/badge.svg)](https://github.com/Emil-02/cachyos-hypr-dotfiles/actions/workflows/ci.yml)
![CachyOS](https://img.shields.io/badge/CachyOS-Arch-1793d1?logo=archlinux&logoColor=white)
![Hyprland](https://img.shields.io/badge/Hyprland-Lua_config-58e1ff)
![License](https://img.shields.io/badge/license-GPL--3.0-blue)

</div>

> 📸 Screenshot menyusul.

## Mode

| Mode | Shell | Cocok untuk | Upstream |
|---|---|---|---|
| **Kerja** (`noctalia`) | Noctalia | Ringan, fokus, terang/gelap otomatis mengikuti wallpaper | [noctalia-dev/noctalia-shell](https://github.com/noctalia-dev/noctalia-shell) |
| **Santai** (`caelestia`) | Caelestia + lockscreen minimalis kustom | Sehari-hari, animasi halus | [caelestia-dots/shell](https://github.com/caelestia-dots/shell) |
| **Mewah** (`end4`) | end-4 illogical-impulse + widget lirik `ii-lyrics` buatan sendiri | Pamer, warna Material You | [end-4/dots-hyprland](https://github.com/end-4/dots-hyprland) |
| **Imut** (`sekaipop`) | SekaiPop + wallpaper hidup | Santai & estetik | [Blapples/SekaiPop](https://github.com/Blapples/SekaiPop) |

Saat berpindah mode, `ganti-mode` menyimpan konfigurasi mode lama, memuat milik mode baru
(Hyprland, terminal, fish, GTK/Qt, fastfetch, btop, dan lain-lain), lalu **mematikan shell lain sepenuhnya**
supaya tidak memakan RAM.

## Fitur

- **`ganti-mode`**: menu Fuzzel (<kbd>SUPER</kbd>+<kbd>F12</kbd>), `ganti-mode toggle`, `ganti-mode status`.
- **Installer aman**: semua file yang akan ditimpa dicadangkan dulu, lalu bisa dikembalikan dengan `./uninstall.sh`.
- **`ii-lyrics`**: widget lirik & musik (desktop / mengambang / karaoke) untuk mode end-4.
- **`buat-wallpaper-hidup`**: mengubah gambar diam jadi video wallpaper loop (efek kelopak, salju, bara, hujan, kunang, kilau).
- **`noctalia-auto-mode`**: tema terang/gelap otomatis berdasarkan kecerahan wallpaper.
- **`noctalia-greeting`**: sapaan di bar sesuai waktu (atur nama lewat `GREETING_NAME`).
- **`wallpaper-acak`**, **`caelestia-wallpaper-cycle`**, **`sekai-fetch`** (logo fastfetch dari potongan wallpaper aktif).
- **`simpan-tampilan`**: snapshot seluruh tampilan ke `~/Backup-Tema-Desktop/profil-<nama>` beserta skrip pemulihan.

## Instalasi

Diuji di **CachyOS** (Hyprland dengan config Lua). Seharusnya juga jalan di Arch atau turunannya dengan `paru`/`yay`.

```bash
git clone https://github.com/Emil-02/cachyos-hypr-dotfiles
cd cachyos-hypr-dotfiles

./install.sh --dry-run          # lihat dulu apa saja yang akan diubah
./install.sh --deps             # pasang paket dasar + terapkan mode Kerja (Noctalia)
```

Mode lain butuh shell-nya dipasang sekali:

```bash
./scripts/install-mode-caelestia.sh   # Santai
./scripts/install-mode-end4.sh        # Mewah
./scripts/install-mode-sekaipop.sh    # Imut
ganti-mode menu
```

Skrip di atas **hanya** memasang paket dan folder shell dari upstream (pada commit yang sudah diuji).
Installer dots bawaan upstream tidak dijalankan, jadi config Hyprland kamu tidak ikut ditimpa.

Membatalkan instalasi:

```bash
./uninstall.sh            # pulihkan cadangan terbaru
./uninstall.sh --list     # lihat semua cadangan
```

## Struktur

```
bin/        skrip → ~/.local/bin
modes/      config per mode → ~/.local/share/mode-tampilan/<mode> (dipakai ganti-mode)
shell/      config shell yang sama untuk semua mode (noctalia, caelestia, sekaipop, ii-lyrics, ...)
packages/   daftar paket dasar
scripts/    pemasang shell tiap mode
lib/        daftar bersama untuk install/sync/uninstall
sync.sh     salin config dari sistem ke repo (path $HOME diganti @HOME@)
```

## Merawat repo ini

```bash
./sync.sh --check   # lihat apa yang berubah di sistem
./sync.sh           # salin ke repo, ganti path pribadi, cek token
git diff && git commit -am "Perbarui tampilan"
```

Wallpaper, stiker, dan gambar logo fastfetch **tidak** disertakan. Taruh gambarmu sendiri di
`~/.config/fastfetch/Koi.png` dan `~/Gambar/Wallpaper/Berkelas/`.

## Kredit & Lisensi

Konfigurasi di sini dikembangkan dari karya [end-4](https://github.com/end-4/dots-hyprland),
[Caelestia](https://github.com/caelestia-dots), [SekaiPop](https://github.com/Blapples/SekaiPop) (GPL-3.0),
dan [Noctalia](https://github.com/noctalia-dev/noctalia-shell) (MIT). Karena itu repo ini dirilis dengan lisensi
[GPL-3.0](LICENSE).
