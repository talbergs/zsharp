{ tool, session, upstream }:
let pkgs = import upstream { };
in with pkgs.lib;
pkgs.mkShell {
  packages = with pkgs; [
    gcc
    postgresql
    zlib
    libevent
    libiconv
    openssl
    curl
    pcre2
  ];
  shellHook = ''
    source ${tool}/rtp.sh
    DST="$(rtp:dst:agents ${session})"

    mk_conf() {
      echo "LogFile=$DST/log"
      # echo "EnableRemoteCommands=1"
      # echo "LogRemoteCommands=1"
      echo "Server=127.0.0.1,0.0.0.0"
    }

    build() {
      [[ ! -e "$DST/conf" ]] && mk_conf > "$DST/conf"

      echo "$DST/conf"
      cat "$DST/conf"

      old="$DST"/sbin/zabbix_agent2
      [[ -e "$old" ]] && $old -f -c "$DST/conf" || "$DST"/sbin/zabbix_agentd -f -c "$DST/conf"

      echo goodbye.
    }

    fg() {
      clear

      echo DST=$DST
      ${getExe pkgs.tree} "$DST"


      [[ -e ""$DST"/sbin/zabbix_agentd" ]] && "$DST"/sbin/zabbix_agentd --version || echo not found

      [[ -e "$DST/conf" ]] \
        && echo Found config: $DST/conf \
        && tput sgr 2 \
        && cat "$DST/conf" \
        && tput sgr 0

        printf "$(tput setaf 2)%s\n%s\n%s\n%s$(tput sgr0)\n\n" \
          "1) Start agent2?" "2) Reset config?" "3) Edit config?"
        read -N 1 -e -p "[1][2][3]>:" var

        case "$var" in
          1)
            set +e
            build
          ;;
          2)
            mk_conf > "$DST/conf"
            fg
          ;;
          3)
            if [ -z "$EDITOR" ]
            then

              printf "$(tput setaf 2)%s\n%s\n%s\n%s$(tput sgr0)\n\n" \
                "1) vim?" \
                "2) nano?" \
                "3) mocro? (Modern and intuitive terminal-based text editor)"
              read -N 1 -e -p "[1][2][3]>:" var

              case "$var" in
                1) ${getExe pkgs.neovim} "$DST/conf" ;;
                2) ${getExe pkgs.nano} "$DST/conf" ;;
                3) ${getExe pkgs.micro} "$DST/conf" ;;
                *) fg ;;
              esac
              
            else
              $EDITOR "$DST/conf"
            fi
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
