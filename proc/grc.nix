{ tool, upstream }:
let
  pkgs = import upstream { };
in pkgs.mkShell {
  packages = with pkgs; [ tailspin ];
  shellHook = ''
    source ${tool}/rtp.sh

    _check() {
      if [ -z "$logfile" ]
      then
        echo ERROR: specify logfile
        exit 7
      fi
      echo Using log file $logfile
    }

    colorizer:php() {
      _check
      touch $logfile
      tail -F $logfile | tspin
    }

    colorizer:c() {
      _check
      touch $logfile
      tail -F $logfile | tspin
    }
  '';
}
