{ prefix, dbname, dbuser, upstream ? <nixpkgs> }:
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
    build() {
      echo "DBName=${dbname}" >> ${prefix}/etc/zabbix_server.conf
      echo "DBUser=${dbuser}" >> ${prefix}/etc/zabbix_server.conf
      echo "LogFile=${prefix}/zabbix_server.log" >> ${prefix}/etc/zabbix_server.conf
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
