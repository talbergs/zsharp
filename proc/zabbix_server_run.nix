{ tool, session, dbname, dbuser, upstream ? <nixpkgs> }:
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
    DST="$(rtp:dst:server ${session})"

    mk_conf() {
        LOGFILE="$DST/log" \
        DB_USER="${dbuser}" \
        DB_NAME="${dbname}" \
      nix run ${tool}#server_conf
    }

    test_config() {
      [[ ! -e "$DST/conf" ]] && mk_conf > "$DST/conf"

      echo "$DST/conf"
      cat "$DST/conf"

      tput setaf 3
      "$DST"/sbin/zabbix_server --test-config -c "$DST/conf"
      tput sgr0

      read -N 1 -e -p "<press any key>:" var
    }

    build() {
      [[ ! -e "$DST/conf" ]] && mk_conf > "$DST/conf"

      echo "$DST/conf"
      cat "$DST/conf"

      "$DST"/sbin/zabbix_server -f -c "$DST/conf"
    }

    fg() {
      clear

      echo DST=$DST
      ${getExe pkgs.tree} "$DST"

      [[ -e "$DST/conf" ]] \
        && echo Found config: $DST/conf \
        && tput sgr 2 \
        && cat "$DST/conf" \
        && tput sgr 0

        printf "$(tput setaf 2)%s\n%s\n%s\n%s$(tput sgr0)\n\n" \
          "1) Start server?" "2) Reset config?" "3) Edit config?" "4) Test config?"
        read -N 1 -e -p "[1][2][3][4]>:" var

        case "$var" in
          1)
            build
            fg
          ;;
          2)
            mk_conf > "$DST/conf"
            fg
          ;;
          3)
            nix run ${tool}#text-edit-picker -- "$DST/conf"
            fg
          ;;
          4)
            test_config
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
