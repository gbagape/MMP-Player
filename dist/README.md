# 🎬 MMP Player (Player Multimedia) v1.0

**MMP Player** este un player multimedia modern, rapid și ușor, compatibil cu mai multe sisteme de operare (**Linux, macOS, Windows**), construit cu **PyQt6** și **libmpv**, având o interfață bilingvă (**Română / Engleză**) și fiind distribuit sub licența **GNU GPL v3**.

---

## ✨ Funcționalități

* 🌐 **Interfață Bilingvă (Română / Engleză):** Detectare automată a limbii sistemului și comutare instantanee din meniul *Opțiuni → 🌐 Limbă*.
* 🎬 **Redare puternică prin `libmpv`:** Decodare accelerată hardware (placă video) și software (procesor), controlul vitezei de redare, raport de aspect, rotire, luminozitate, derulare cadru cu cadru și capturi de ecran.
* 💬 **Subtitrări avansate:** Încărcare automată, **34 de codări de caractere** (inclusiv *UTF-8*, *CP1250*, *ISO-8859-16*), detectare automată a limbii, personalizare font, culori, contur, opacitate și buton **Aplică** în timp real.
* 🎨 **3 Teme integrate:** *Întunecat Modern*, *Albastru Nocturn* și *SMPlayer Clasic (Luminos)*.
* 📜 **Licență GNU GPL v3:** Vizualizare directă a licenței din *Ajutor → Despre MMP Player* și acceptarea acesteia la instalare.

---

## 📦 Instalare

### 1. Program de instalare universal Linux (pentru orice distribuție)
Instalează automat pachetele necesare (`python3`, `PyQt6`, `mpv`, `python-mpv`), afișează licența GNU GPL v3 și integrează aplicația în meniul sistemului:

```bash
chmod +x MMP-Player-1.0-Linux-Universal.run
./MMP-Player-1.0-Linux-Universal.run
```

* **Instalare automată (fără confirmări manuale):**
  ```bash
  ./MMP-Player-1.0-Linux-Universal.run --accept-license
  ```
* **Dezinstalare:**
  ```bash
  ./MMP-Player-1.0-Linux-Universal.run --uninstall
  ```

---

### 2. Pachete native și rețete de compilare pentru Linux

| Distribuție | Comandă de instalare |
| :--- | :--- |
| **Arch Linux / Manjaro / EndeavourOS** | `sudo pacman -U mmp-player-1.0-1-any.pkg.tar.zst` |
| **Debian / Ubuntu / Linux Mint** | `sudo apt install ./mmp-player_1.0_all.deb` |
| **Fedora / PCLinuxOS / RHEL / Nobara** | `sudo dnf install ./mmp-player-1.0-1.noarch.rpm` |
| **openSUSE Tumbleweed / Leap** | `sudo zypper install ./mmp-player-1.0-1.noarch.rpm` |
| **Slackware** | `sudo installpkg mmp-player-1.0-noarch-1.txz` |
| **Alpine Linux** | `sudo apk add --allow-untrusted mmp-player-1.0-r0.apk` |
| **Gentoo Linux (`.ebuild`)** | `sudo cp dist/gentoo/mmp-player-1.0.ebuild /var/db/repos/local/media-video/mmp-player/ && sudo ebuild /var/db/repos/local/media-video/mmp-player/mmp-player-1.0.ebuild manifest && sudo emerge -av media-video/mmp-player` |
| **Void Linux (`xbps-src`)** | `cp -r dist/void /path/to/void-packages/srcpkgs/mmp-player && ./xbps-src pkg mmp-player && sudo xbps-install --repository=hostdir/binpkgs mmp-player` |
| **NixOS / Nix** | `nix-env -if dist/nix/default.nix` *(sau `nix-build dist/nix/default.nix`)* |
| **Versiune portabilă (`AppImage`)** | `chmod +x MMP-Player-1.0-x86_64.AppImage && ./MMP-Player-1.0-x86_64.AppImage` |
| **Din codul sursă (`.tar.gz`)** | `tar -xzf MMP-Player-1.0-RO-EN-GPLv3.tar.gz && ./install.sh` |

---

### 3. macOS (`MMP-Player-1.0-macOS.app.zip`)

1. Dezarhivați `MMP-Player-1.0-macOS.app.zip` și mutați aplicația **MMP Player.app** în directorul **Applications** (Aplicații).
2. La prima deschidere, faceți **Click-dreapta → Deschide** (necesar pentru aplicațiile distribuite în afara magazinului oficial Apple).
3. Dacă pe sistem este instalat [Homebrew](https://brew.sh), lansatorul va instala automat la prima pornire componentele necesare (`mpv`, `yt-dlp`, `fluid-soundfont`, `PyQt6`, `python-mpv`).

---

### 4. Windows (`MMP-Player-1.0-Windows-Setup.exe`)

1. Rulați **MMP-Player-1.0-Windows-Setup.exe** și urmați pașii din asistentul de instalare.
2. Pachetul include motorul multimedia `libmpv-2.dll`, scurtături pe Desktop / în Meniul Start și programul de dezinstalare (`Uninstall.exe`).
3. La prima pornire, lansatorul configurează automat bibliotecile Python necesare (`PyQt6`, `python-mpv`, `yt-dlp`) prin `winget` / `pip`.

---

## ⌨️ Scurtături utile de tastatură

* `Spațiu` — Redare / Pauză
* `F` sau Dublu-click — Comutare ecran complet
* `M` — Oprire / Pornire sunet (Mut)
* `S` — Captură de ecran
* `Ctrl + P` — Preferințe
* `N` — Deschide adresă web / flux video
* `Z` / `X` — Decalaj subtitrare -0,1s / +0,1s
* `R` / `T` — Mutare poziție subtitrare sus / jos
* `.` / `,` — Pas cadru înainte / înapoi

---

## 📜 Licență

Acest proiect este distribuit sub termenii licenței **GNU General Public License v3.0 (GPL-3.0-or-later)**. Consultați fișierul [`LICENSE`](LICENSE) pentru textul integral.
