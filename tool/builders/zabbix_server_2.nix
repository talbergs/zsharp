{ upstream ? <nixpkgs> }:
let pkgs = import upstream { };
in with pkgs.lib;
pkgs.mkShell {
  packages = with pkgs; [
    gcc
    postgresql
    automake
    autoconf
    zlib
    libevent
    libiconv
    openssl
    curl
    pcre2
  ];
  shellHook = ''
    dst="$DST"
    src="$SRC"

    build() {
      ./bootstrap.sh
      ./configure \
        --enable-server \
        --with-postgresql \
        --prefix="$dst" \
        --with-zlib=${pkgs.zlib} \
        --with-libevent \
        --with-libpcre2=$(dirname $(which pcre2-config))/..

      make clean -j6
      make install -j6

      ${getExe pkgs.tree} "$dst"
      if [[ -e ${prefix}/sbin/zabbix_server ]]
      then
        echo "Build revision: $ZABBIX_REVISION" > ${prefix}/ZABBIX_REVISION
        ${prefix}/sbin/zabbix_server --version >> ${prefix}/ZABBIX_REVISION
        ${prefix}/sbin/zabbix_server --version
      fi
    }

    fg() {
      ${getExe pkgs.tree} "$dst"
      ${getExe pkgs.tree} "$dst"
      export ZABBIX_REVISION=$(${getExe pkgs.git} rev-parse HEAD)
      if read -r -p "Build server sources $PWD?"
      then
        build
      fi
    }
  '';
}
