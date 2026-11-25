import os, sys
from PyQt6.QtGui import QImage, QPixmap
from PyQt6.QtCore import Qt
from PyQt6.QtWidgets import QApplication

app = QApplication(sys.argv)

src_png = "assets/mmp-player.png"
if not os.path.isfile(src_png):
    print("❌ Nu am găsit assets/mmp-player.png! Salvează mai întâi imaginea acolo.")
    sys.exit(1)

img = QImage(src_png)
if img.isNull():
    print("❌ Fișierul assets/mmp-player.png nu este o imagine validă.")
    sys.exit(1)

# 1. Generam toate dimensiunile standard hicolor
os.makedirs("assets/icons", exist_ok=True)
for sz in (16, 24, 32, 48, 64, 128, 256, 512):
    scaled = img.scaled(sz, sz, Qt.AspectRatioMode.KeepAspectRatio, Qt.TransformationMode.SmoothTransformation)
    scaled.save(f"assets/icons/mmp-player-{sz}.png", "PNG")

# Pastram si o versiune 256x256 principala
img.scaled(256, 256, Qt.AspectRatioMode.KeepAspectRatio, Qt.TransformationMode.SmoothTransformation).save("assets/mmp-player.png", "PNG")
if os.path.exists("assets/mmp-player.svg"):
    os.remove("assets/mmp-player.svg")

print("✅ Au fost generate toate dimensiunile PNG (16x16 -> 512x512).")

# 2. Injectam setWindowIcon in src/mmp-player (fereastra principala + dialoguri + taskbar)
with open("src/mmp-player", "r", encoding="utf-8") as f:
    cod = f.read()

if "QIcon" not in cod.split("class ")[0]:
    cod = cod.replace("from PyQt6.QtGui import ", "from PyQt6.QtGui import QIcon, ", 1)

cod_icon = '''
def gaseste_iconita_mmp():
    baza = os.path.dirname(os.path.abspath(__file__))
    cai = (
        os.path.join(baza, "..", "assets", "mmp-player.png"),
        os.path.join(baza, "mmp-player.png"),
        os.path.expanduser("~/.local/share/icons/hicolor/256x256/apps/mmp-player.png"),
        "/usr/local/share/icons/hicolor/256x256/apps/mmp-player.png",
        "/usr/share/icons/hicolor/256x256/apps/mmp-player.png",
        "/usr/share/pixmaps/mmp-player.png",
    )
    for c in cai:
        if os.path.isfile(c):
            return QIcon(c)
    return QIcon.fromTheme("mmp-player")
'''

if "def gaseste_iconita_mmp" not in cod:
    cod = cod.replace("class FereastraPreferinte", cod_icon + "\nclass FereastraPreferinte", 1)

if "app.setWindowIcon" not in cod:
    cod = cod.replace(
        "app = QApplication(sys.argv)",
        'app = QApplication(sys.argv)\n    app.setDesktopFileName("mmp-player")\n    app.setWindowIcon(gaseste_iconita_mmp())',
        1
    )

with open("src/mmp-player", "w", encoding="utf-8") as f:
    f.write(cod)
os.chmod("src/mmp-player", 0o755)
print("✅ Iconița a fost conectată în src/mmp-player (fereastră + taskbar Wayland/X11).")
