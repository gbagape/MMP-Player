[![Download MMP Player v1.1](https://shields.io)](https://github.com/gbagape/MMP-Player/releases/tag/v1.1)

# 🎬 MMP Player (Multimedia Player) v1.1

**MMP Player** is a fast, lightweight, and modern cross-platform multimedia player (**Linux, macOS, Windows**) powered by **PyQt6** and **libmpv**, featuring a bilingual interface (**English / Romanian**) and licensed under **GNU GPL v3**.

---

## ✨ Features

* 🌐 **Bilingual Interface (EN / RO):** Automatic system language detection + instant switching from *Options → 🌐 Language*.
* 🎬 **Powerful Playback via `libmpv`:** Hardware (GPU) and software (CPU) decoding, playback speed control, aspect ratio, rotation, brightness, frame-by-frame stepping, and screenshots.
* 💬 **Advanced Subtitles:** Auto-loading, **34 character encodings** (including *UTF-8*, *CP1250*, *ISO-8859-16*), language auto-detection, custom font/colors/outline/opacity, and real-time **Apply** button.
* 🎨 **3 Built-in Themes:** *Dark Modern*, *Midnight Blue*, and *SMPlayer Classic (Light)*.
* 📜 **GNU GPL v3 License:** Built-in license viewer under *Help → About MMP Player* and license acceptance during installation.

---

## 📦 Installation

> 📥 **Download all installers (Linux, macOS, Windows) from [GitHub Releases v1.1](https://github.com/gbagape/MMP-Player/releases/tag/v1.1)**


### 1. Universal Linux Installer (Any Linux distro)
Automatically installs dependencies (`python3`, `PyQt6`, `mpv`, `python-mpv`), displays the GNU GPL v3 license, and integrates the application into your desktop menu:

```bash
chmod +x MMP-Player-1.1-Linux-Universal.run
./MMP-Player-1.1-Linux-Universal.run
```

* **Unattended install (no prompts):**
  ```bash
  ./MMP-Player-1.1-Linux-Universal.run --accept-license
  ```
* **Uninstall:**
  ```bash
  ./MMP-Player-1.1-Linux-Universal.run --uninstall
  ```

---

### 2. Linux Native Packages & Build Recipes

| Distribution | Install Command |
| :--- | :--- |
| **Arch Linux / Manjaro / EndeavourOS** | `sudo pacman -U mmp-player-1.1-1-any.pkg.tar.zst` |
| **Ubuntu / Linux Mint (Official PPA — 22.04+)** | `sudo add-apt-repository -y ppa:gbagape/mmp-player && sudo apt update && sudo apt install -y mmp-player` |
| **Debian / Ubuntu / Linux Mint (Manual .deb)** | `sudo apt install ./mmp-player_1.1_all.deb` |
| **Fedora / PCLinuxOS / RHEL / Nobara** | `sudo dnf install ./mmp-player-1.1-1.noarch.rpm` |
| **openSUSE Tumbleweed / Leap** | `sudo zypper install ./mmp-player-1.1-1.noarch.rpm` |
| **Slackware** | `sudo installpkg mmp-player-1.1-noarch-1.txz` |
| **Alpine Linux** | `sudo apk add --allow-untrusted mmp-player-1.1-r0.apk` |
| **Gentoo Linux (`.ebuild`)** | `sudo cp dist/gentoo/mmp-player-1.1.ebuild /var/db/repos/local/media-video/mmp-player/ && sudo ebuild /var/db/repos/local/media-video/mmp-player/mmp-player-1.1.ebuild manifest && sudo emerge -av media-video/mmp-player` |
| **Void Linux (`xbps-src`)** | `cp -r dist/void /path/to/void-packages/srcpkgs/mmp-player && ./xbps-src pkg mmp-player && sudo xbps-install --repository=hostdir/binpkgs mmp-player` |
| **NixOS / Nix** | `nix-env -if dist/nix/default.nix` *(or `nix-build dist/nix/default.nix`)* |
| **Portable (`AppImage`)** | `chmod +x MMP-Player-1.1-x86_64.AppImage && ./MMP-Player-1.1-x86_64.AppImage` |
| **From Source (`.tar.gz`)** | `tar -xzf MMP-Player-1.1-RO-EN-GPLv3.tar.gz && ./install.sh` |

---

### 3. macOS (`MMP-Player-1.1-macOS.app.zip`)

1. Extract `MMP-Player-1.1-macOS.app.zip` and move **MMP Player.app** to your **Applications** folder.
2. On first launch, **Right-click → Open** (required for apps distributed outside the Mac App Store).
3. If [Homebrew](https://brew.sh) is installed on your Mac, the launcher automatically installs the required dependencies (`mpv`, `yt-dlp`, `fluid-soundfont`, `PyQt6`, `python-mpv`) on first run.

---

### 4. Windows (`MMP-Player-1.1-Windows-Setup.exe`)

1. Run **MMP-Player-1.1-Windows-Setup.exe** and follow the setup wizard.
2. Bundles the `libmpv-2.dll` multimedia engine, Desktop / Start Menu shortcuts, and an uninstaller (`Uninstall.exe`).
3. On first launch, the starter automatically configures any missing Python dependencies (`PyQt6`, `python-mpv`, `yt-dlp`) via `winget` / `pip`.

---

## ⌨️ Useful Shortcuts

* `Space` — Play / Pause
* `F` or Double-click — Toggle Fullscreen
* `M` — Mute
* `S` — Take Screenshot
* `Ctrl + P` — Preferences
* `N` — Open URL / Stream
* `Z` / `X` — Subtitle delay -0.1s / +0.1s
* `R` / `T` — Move subtitle position up / down
* `.` / `,` — Frame step forward / backward

---

## 📜 License

This project is distributed under the terms of the **GNU General Public License v3.0 (GPL-3.0-or-later)**. See the [`LICENSE`](LICENSE) file for the full text.
