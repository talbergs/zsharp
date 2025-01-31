{ tool, prefix, dbname, dbuser, upstream ? <nixpkgs> }:
let
  pkgs = import upstream { };
in
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
    mk_conf() {
      nix run ${tool}#server_conf -- \
        LogFile="${prefix}/zabbix_server.log" \
        DBName="${dbname}" \
        DBUser="${dbuser}"
    }
    build() {
      [[ ! -e "${prefix}/zabbix_server.log" ]] && mk_conf > "${prefix}/zabbix_server.log"

      ${prefix}/sbin/zabbix_server -f
    }


    fg() {
      cat ${prefix}/ZABBIX_REVISION
      if read -r -p "Configure and run server?"
      then
        build
      fi
    }
  '';
}
