{ upstream ? <nixpkgs> }:
let pkgs = import upstream { };
rtp = ../rtp.sh;
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

    set -x

    build() {
      cd "$src"
      source ${rtp}
      sandbox:cd "$src" "$(basename $src)/server"
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
    }

    fg() {
      ${getExe pkgs.tree} "$dst"
      export ZABBIX_REVISION=$(${getExe pkgs.git} rev-parse HEAD)
      if read -r -p "Build server from $src?"
      then
        build
      fi
    }
  '';
}
