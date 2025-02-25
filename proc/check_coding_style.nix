{ tool, upstream }:
let
  pkgs = import upstream { };
in
pkgs.mkShell {
  shellHook = ''
    source ${tool}/rtp.sh

    fg() {
      clear

      printf "$(tput setaf 2)%s\n%s\n%s$(tput sgr0)\n\n" \
        "1) Scan php files in $PWD?"
      read -N 1 -e -p "[1]>:" var

      case "$var" in
        1)
          nix run ${tool}#guideliner
          echo Done.
        ;;
        *)
          echo "Choose an option."
          fg
        ;;
      esac
    }
  '';
}
