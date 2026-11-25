#!/usr/bin/env bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE}")" && pwd)"
AUTO_ACCEPT=0
UNINSTALL=0
FORCE_CLI=0

for arg in "$@"; do
    case "$arg" in
        --accept-license|-y) AUTO_ACCEPT=1 ;;
        --uninstall) UNINSTALL=1 ;;
        --cli|--no-gui) FORCE_CLI=1 ;;
    esac
done

LANG_SYS="${LANG:-en}"
IS_RO=0
[[ "$LANG_SYS" == ro* ]] && IS_RO=1

ruleaza_ca_admin() {
    local script_tmp
    script_tmp="$(mktemp /tmp/mmp-admin.XXXXXX.sh)"
    cat > "$script_tmp"
    chmod 755 "$script_tmp"
    if [[ $EUID -eq 0 ]]; then
        bash "$script_tmp"
    elif [[ $FORCE_CLI -eq 0 && ( -n "$DISPLAY" || -n "$WAYLAND_DISPLAY" ) ]] && command -v pkexec >/dev/null 2>&1; then
        pkexec bash "$script_tmp"
    elif command -v sudo >/dev/null 2>&1; then
        sudo bash "$script_tmp"
    else
        rm -f "$script_tmp"
        return 1
    fi
    local rc=$?
    rm -f "$script_tmp"
    return $rc
}

executa_dezinstalare() {
    ruleaza_ca_admin << 'ADMIN_UNINST'
set -e
rm -f /usr/local/bin/mmp-player /usr/local/share/applications/mmp-player.desktop /usr/local/share/pixmaps/mmp-player.png
for sz in 16 24 32 48 64 128 256 512; do
    rm -f "/usr/local/share/icons/hicolor/${sz}x${sz}/apps/mmp-player.png"
done
rm -rf /usr/local/share/licenses/mmp-player
update-desktop-database /usr/local/share/applications 2>/dev/null || true
ADMIN_UNINST
}

executa_instalare() {
    ruleaza_ca_admin << ADMIN_INST
set -e
if command -v apt-get >/dev/null 2>&1; then
    apt-get update -qq && (apt-get install -y python3 python3-pyqt6 libmpv2 python3-mpv || apt-get install -y python3 python3-pyqt6 libmpv1 python3-pip)
elif command -v pacman >/dev/null 2>&1; then
    pacman -Sy --needed --noconfirm python python-pyqt6 mpv python-mpv
elif command -v dnf >/dev/null 2>&1; then
    dnf install -y python3 python3-qt6 mpv-libs python3-pip
elif command -v zypper >/dev/null 2>&1; then
    zypper install -y python3 python3-qt6 libmpv2 python3-pip
elif command -v apk >/dev/null 2>&1; then
    apk add --no-cache python3 py3-qt6 mpv-libs py3-pip
elif command -v xbps-install >/dev/null 2>&1; then
    xbps-install -Sy python3 python3-PyQt6 mpv python3-pip
elif command -v emerge >/dev/null 2>&1; then
    emerge --noreplace dev-lang/python dev-python/pyqt6 media-video/mpv dev-python/python-mpv
fi

mkdir -p /usr/local/bin /usr/local/share/applications /usr/local/share/pixmaps /usr/local/share/licenses/mmp-player
install -m 755 "$DIR/src/mmp-player" /usr/local/bin/mmp-player
install -m 644 "$DIR/assets/mmp-player.desktop" /usr/local/share/applications/mmp-player.desktop
install -m 644 "$DIR/assets/mmp-player.png" /usr/local/share/pixmaps/mmp-player.png
for sz in 16 24 32 48 64 128 256 512; do
    if [[ -f "$DIR/assets/icons/mmp-player-\${sz}.png" ]]; then
        mkdir -p "/usr/local/share/icons/hicolor/\${sz}x\${sz}/apps"
        install -m 644 "$DIR/assets/icons/mmp-player-\${sz}.png" "/usr/local/share/icons/hicolor/\${sz}x\${sz}/apps/mmp-player.png"
    fi
done
install -m 644 "$DIR/LICENSE" /usr/local/share/licenses/mmp-player/LICENSE
update-desktop-database /usr/local/share/applications 2>/dev/null || true
gtk-update-icon-cache -f -t /usr/local/share/icons/hicolor 2>/dev/null || true
ADMIN_INST

    if ! python3 -c "import mpv" >/dev/null 2>&1; then
        python3 -m pip install --user --break-system-packages mpv 2>/dev/null || \
        python3 -m pip install --user mpv 2>/dev/null || true
    fi
}

# ==============================================================================
# MOD GRAFIC (GUI la dublu-click)
# ==============================================================================
if [[ $FORCE_CLI -eq 0 && $AUTO_ACCEPT -eq 0 && $UNINSTALL -eq 0 && ( -n "$DISPLAY" || -n "$WAYLAND_DISPLAY" ) ]]; then
    if python3 -c "import PyQt6.QtWidgets" >/dev/null 2>&1; then
        MMP_DIR="$DIR" MMP_IS_RO="$IS_RO" python3 - << 'PYGUI'
import os, sys, subprocess
from PyQt6.QtWidgets import (QApplication, QDialog, QVBoxLayout, QHBoxLayout, QLabel,
                             QTextEdit, QCheckBox, QPushButton, QMessageBox, QProgressBar)
from PyQt6.QtGui import QIcon, QPixmap, QTextCursor
from PyQt6.QtCore import Qt, QThread, pyqtSignal

IS_RO = os.environ.get("MMP_IS_RO") == "1"
BDIR = os.environ.get("MMP_DIR", ".")

class Worker(QThread):
    done = pyqtSignal(bool, str)
    def __init__(self, func_name):
        super().__init__()
        self.func_name = func_name
    def run(self):
        cmd = f'source "{BDIR}/install.sh" --cli; {self.func_name}'
        p = subprocess.run(["bash", "-c", cmd], capture_output=True, text=True)
        out = (p.stdout + "\n" + p.stderr).strip()
        self.done.emit(p.returncode == 0, out)

app = QApplication(sys.argv)
dlg = QDialog()
dlg.setWindowTitle("MMP Player v1.0 - Instalare" if IS_RO else "MMP Player v1.0 - Setup")
dlg.resize(640, 500)
ico_path = os.path.join(BDIR, "assets", "mmp-player.png")
if os.path.isfile(ico_path):
    dlg.setWindowIcon(QIcon(ico_path))

lay = QVBoxLayout(dlg)
hdr = QHBoxLayout()
if os.path.isfile(ico_path):
    lbl_ico = QLabel()
    lbl_ico.setPixmap(QPixmap(ico_path).scaled(56, 56, Qt.AspectRatioMode.KeepAspectRatio, Qt.TransformationMode.SmoothTransformation))
    hdr.addWidget(lbl_ico)

titlu = QLabel(
    "<h2>Instalare MMP Player (Multimedia Player) v1.0</h2><p>Licență: <b>GNU General Public License v3.0 (GPL-3.0)</b></p>"
    if IS_RO else
    "<h2>MMP Player (Multimedia Player) v1.0 Setup</h2><p>License: <b>GNU General Public License v3.0 (GPL-3.0)</b></p>"
)
hdr.addWidget(titlu, 1)
lay.addLayout(hdr)

txt_lic = QTextEdit()
txt_lic.setReadOnly(True)
lic_file = os.path.join(BDIR, "LICENSE")
if os.path.isfile(lic_file):
    with open(lic_file, "r", encoding="utf-8", errors="ignore") as f:
        txt_lic.setPlainText(f.read())
txt_lic.moveCursor(QTextCursor.MoveOperation.Start)
lay.addWidget(txt_lic)

chk = QCheckBox(
    "Accept termenii licenței GNU GPL v3 și doresc instalarea MMP Player."
    if IS_RO else
    "I accept the terms of the GNU GPL v3 license and want to install MMP Player."
)
lay.addWidget(chk)

lbl_status = QLabel("")
lbl_status.setVisible(False)
lay.addWidget(lbl_status)

pbar = QProgressBar()
pbar.setRange(0, 0)
pbar.setVisible(False)
lay.addWidget(pbar)

btns = QHBoxLayout()
btn_uninst = QPushButton("🗑️ Dezinstalează" if IS_RO else "🗑️ Uninstall")
btn_inst = QPushButton("⬇️ Instalează MMP Player" if IS_RO else "⬇️ Install MMP Player")
btn_inst.setEnabled(False)
btn_inst.setStyleSheet("font-weight: bold; padding: 6px 14px;")
btn_cancel = QPushButton("Anulează" if IS_RO else "Cancel")

chk.toggled.connect(btn_inst.setEnabled)
btn_cancel.clicked.connect(dlg.reject)

btns.addWidget(btn_uninst)
btns.addStretch()
btns.addWidget(btn_cancel)
btns.addWidget(btn_inst)
lay.addLayout(btns)

def porneste(mode):
    btn_inst.setEnabled(False)
    btn_uninst.setEnabled(False)
    chk.setEnabled(False)
    lbl_status.setText("⏳ Se așteaptă autentificarea administratorului și se instalează..." if IS_RO else "⏳ Waiting for administrator authentication and installing...")
    lbl_status.setVisible(True)
    pbar.setVisible(True)
    fn = "executa_dezinstalare" if mode == "uninstall" else "executa_instalare"
    dlg.worker = Worker(fn)
    def fin(ok, out):
        pbar.setVisible(False)
        lbl_status.setVisible(False)
        if ok:
            if mode == "install":
                r = QMessageBox.question(
                    dlg,
                    "Instalare finalizată" if IS_RO else "Installation Complete",
                    ("MMP Player a fost instalat cu succes în /usr/local/bin/mmp-player!\nDoriți să îl porniți acum?"
                     if IS_RO else
                     "MMP Player has been installed successfully to /usr/local/bin/mmp-player!\nWould you like to launch it now?")
                )
                if r == QMessageBox.StandardButton.Yes:
                    subprocess.Popen(["mmp-player"])
            else:
                QMessageBox.information(dlg, "Dezinstalare" if IS_RO else "Uninstall",
                                        "MMP Player a fost dezinstalat." if IS_RO else "MMP Player has been uninstalled.")
            dlg.accept()
        else:
            QMessageBox.critical(dlg, "Eroare" if IS_RO else "Error", out[-1200:] if out else ("Autentificare anulată sau eroare la instalare." if IS_RO else "Authentication cancelled or installation error."))
            btn_inst.setEnabled(chk.isChecked())
            btn_uninst.setEnabled(True)
            chk.setEnabled(True)
    dlg.worker.done.connect(fin)
    dlg.worker.start()

btn_inst.clicked.connect(lambda: porneste("install"))
btn_uninst.clicked.connect(lambda: porneste("uninstall"))

dlg.exec()
PYGUI
        exit 0
    fi
fi

if [[ "${BASH_SOURCE}" == "${0}" ]]; then
    if [[ $UNINSTALL -eq 1 ]]; then
        executa_dezinstalare
        [[ $IS_RO -eq 1 ]] && echo "🗑️ MMP Player a fost dezinstalat." || echo "🗑️ MMP Player has been uninstalled."
        exit 0
    fi

    if [[ $IS_RO -eq 1 ]]; then
        echo "=== MMP Player v1.0 - Installer Universal Linux (GNU GPL v3) ==="
        if [[ $AUTO_ACCEPT -eq 0 ]]; then
            read -rp "Acceptați termenii licenței GNU GPL v3 și continuați instalarea? [d/N]: " ans
            [[ "$ans" =~ ^[dDyY]$ ]] || { echo "Instalare anulată."; exit 1; }
        fi
    else
        echo "=== MMP Player v1.0 - Universal Linux Installer (GNU GPL v3) ==="
        if [[ $AUTO_ACCEPT -eq 0 ]]; then
            read -rp "Do you accept the GNU GPL v3 license terms and continue? [y/N]: " ans
            [[ "$ans" =~ ^[yY]$ ]] || { echo "Installation cancelled."; exit 1; }
        fi
    fi

    executa_instalare
    [[ $IS_RO -eq 1 ]] && echo "✅ MMP Player a fost instalat cu succes!" || echo "✅ MMP Player was successfully installed!"
fi
