{ session, tool, upstream ? <nixpkgs> }:
let pkgs = import upstream { };
in with pkgs.lib;
pkgs.mkShell {
  shellHook = ''
    export ZABBIX_REVISION="$(${getExe pkgs.git} rev-parse HEAD)"
    source ${tool}/rtp.sh

    fg() {
      clear
      ${getExe pkgs.tree} "$(rtp:dst:agents ${session})"
      echo DST="$(rtp:dst:agents ${session})"
      echo SRC="$PWD"

      printf "$(tput setaf 2)%s\n%s$(tput sgr0)\n\n" \
        "1) Build agents 1 and 2?"
      read -N 1 -e -p "[1]>:" var

      case "$var" in
        1)
          DST="$(rtp:dst:agents ${session})" \
          SRC="$PWD" \
            nix-shell ${tool}/builders/zabbix_agents.nix --run build

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
