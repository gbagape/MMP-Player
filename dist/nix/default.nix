{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation rec {
  pname = "mmp-player";
  version = "1.0";

  src = ./../MMP-Player-1.0-RO-EN-GPLv3.tar.gz;
  sourceRoot = ".";

  nativeBuildInputs = [ pkgs.makeWrapper ];
  buildInputs = [
    pkgs.mpv
    (pkgs.python3.withPackages (ps: with ps; [ pyqt6 python-mpv ]))
  ];

  installPhase = ''
    install -Dm755 src/mmp-player $out/bin/mmp-player
    install -Dm644 assets/mmp-player.desktop $out/share/applications/mmp-player.desktop
    install -Dm644 assets/mmp-player.png $out/share/icons/hicolor/256x256/apps/mmp-player.png
    install -Dm644 LICENSE $out/share/licenses/mmp-player/LICENSE
    wrapProgram $out/bin/mmp-player \
      --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath [ pkgs.mpv ]}"
  '';

  meta = with pkgs.lib; {
    description = "MMP Player (Multimedia Player) powered by PyQt6 and libmpv (RO/EN)";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
