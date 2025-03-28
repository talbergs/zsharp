{ tool, dbname, session, upstream }:
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
    DST="$(rtp:dst:proxy ${session})"

    mk_conf() {
      echo "LogFile=$DST/log"
      echo "Server=127.0.0.1"
      echo "DBName=${dbname}"
      echo "Hostname=${dbname}"
      # Passive mode:
      echo "ProxyMode=1"
      echo "ListenPort=10055"
    }

    build() {
      [[ ! -e "$DST/conf" ]] && mk_conf > "$DST/conf"

      echo "$DST/conf"
      cat "$DST/conf"

      "$DST"/sbin/zabbix_proxy -f -c "$DST/conf"

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
          "1) Start proxy?" "2) Reset config?" "3) Edit config?"
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
            nix run ${tool}#text-edit-picker -- "$DST/conf"
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
