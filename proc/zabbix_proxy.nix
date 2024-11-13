{ prefix, upstream ? <nixpkgs> }:
let pkgs = import upstream { };
in pkgs.mkShell {
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
    build() {
      mkdir -p ${prefix}
      ./bootstrap.sh
      ./configure \
        --enable-proxy \
        --prefix=${prefix} \
        --with-zlib=${pkgs.zlib} \
        --with-libevent \
        --with-libpcre2=$(dirname $(which pcre2-config))/..

      make clean -j6
      make install -j6

      ${pkgs.lib.getExe pkgs.tree} ${prefix}
    }

    fg() {
      ${pkgs.lib.getExe pkgs.tree} ${prefix}
      if read -r -p "Build proxy?"
      then
        build
      fi
    }
  '';
}
