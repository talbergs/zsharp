{ logfile, upstream ? <nixpkgs> }:
let
  pkgs = import upstream { };
  colorizer = {
    _mk = name: conf:
      pkgs.writeShellScriptBin "colorizer:${name}" ''
        touch ${logfile}
        tail -F ${logfile} | grcat <(printf "${conf}")
      '';
    z = colorizer._mk "z" ''
      regexp=([.*?])((.*?))(.*?))
      colors=cyan,yellow,green'';
    php = colorizer._mk "php" ''
      regexp=(^[.*?]s(.*?)s)
      colors=cyan,yellow'';
  };
in pkgs.mkShell { packages = with colorizer; [ php z ]; }
