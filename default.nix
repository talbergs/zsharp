{ pkgs, system-db, ... }:
with pkgs;
with pkgs.lib;
let
  main_layout = writeTextFile {
    name = "main.kdl";
    text = (
      import ./main.kdl.nix {
        inherit pkgs;
        inherit system-db;
      }
    );
  };
in
pkgs.stdenv.mkDerivation {
  name = "zashboard";
  src = ./.;
  installPhase = ''
    mkdir -p $out/etc
    conf=$out/etc/zashboard.conf
    head -n 3 ${./zashboard.sh} > $conf

    mkdir -p $out/bin
    touch $out/bin/zashboard
    chmod +x $out/bin/zashboard

    echo ${getExe bash} ${./zashboard.sh} $conf > $out/bin/zashboard
    echo ${getExe zellij} --layout ${main_layout} >> $out/bin/zashboard
  '';
}
