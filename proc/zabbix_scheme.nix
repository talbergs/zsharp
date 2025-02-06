{ tool, upstream ? <nixpkgs> }:
let
  pkgs = import upstream { };
in
with pkgs.lib;
pkgs.mkShell {
  shellHook = ''
    export ZABBIX_REVISION="$(${getExe pkgs.git} rev-parse HEAD)"
    source ${tool}/rtp.sh

    fg() {
      echo "List: $(rtp:db_scheme)"
      ${getExe pkgs.tree} "$(rtp:db_scheme)"

      printf "$(tput setaf 2)%s\n%s$(tput sgr0)\n\n" \
        "1) Build db_scheme?"
      read -N 1 -e -p "[1]>:" var

      case "$var" in
        1)
          DST="$(rtp:db_scheme)" \
          SRC="$PWD" \
            nix run ${tool}#db_scheme
          fg
        ;;
        *)
          echo "Choose an option."
          fg
        ;;
      esac
    }
  '';
}
