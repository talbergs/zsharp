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
        --prefix=${prefix} \
        --with-libpcre2=$(dirname $(which pcre2-config))/.. \
        --enable-agent2

      make clean -j6
      make install -j6

      ${pkgs.lib.getExe pkgs.tree} ${prefix}
    }

    fg() {
      ${pkgs.lib.getExe pkgs.tree} ${prefix}
      if read -r -p "Build agent2?"
      then
        build
      fi
    }
  '';
}
