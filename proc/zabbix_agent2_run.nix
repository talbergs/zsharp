{ prefix, upstream ? <nixpkgs> }:
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
      echo "LogFile=${prefix}/zabbix_agent2.log" >> ${prefix}/etc/zabbix_agent2.conf
      ${prefix}/sbin/zabbix_agent2 -f
    }

    fg() {
      if read -r -p "Configure and run agent?"
      then
        build
      fi
    }
  '';
}
