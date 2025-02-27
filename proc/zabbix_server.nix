{ session, tool, upstream ? <nixpkgs> }:
let pkgs = import upstream { };
in with pkgs.lib;
pkgs.mkShell {
  shellHook = ''
    export ZABBIX_REVISION="$(${getExe pkgs.git} rev-parse HEAD)"
    source ${tool}/rtp.sh

    fg() {
      clear
      ${getExe pkgs.tree} "$(rtp:dst:server ${session})"
      echo DST="$(rtp:dst:server ${session})"
      echo SRC="$PWD"

      printf "$(tput setaf 2)%s\n%s$(tput sgr0)\n\n" \
        "1) Build server?"
      read -N 1 -e -p "[1]>:" var

      case "$var" in
        1)
          DST="$(rtp:dst:server ${session})" \
          SRC="$PWD" \
            nix-shell ${tool}/builders/zabbix_server.nix --run build

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
