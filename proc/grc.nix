{ logfile, upstream ? <nixpkgs> }:
let
  pkgs = import upstream { };
in pkgs.mkShell {
  packages = with pkgs; [ tailspin ];
  shellHook = ''
    colorizer:php() {
      touch ${logfile}
      tail -F ${logfile} | tspin
    }

    colorizer:c() {
      touch ${logfile}
      tail -F ${logfile} | tspin
    }
  '';
}
