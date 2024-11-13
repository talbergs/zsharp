{ prefix, upstream ? <nixpkgs> }:
let pkgs = import upstream { };
in pkgs.mkShell {
  packages = with pkgs; [
    gcc
    automake
    autoconf
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
      mkdir -p ${prefix}
      ./bootstrap.sh
      ./configure \
        --prefix=${prefix} \
        --with-libpcre2=$(dirname $(which pcre2-config))/.. \
        --enable-agent

      make clean -j6
      make install -j6

      ${pkgs.lib.getExe pkgs.tree} ${prefix}
    }

    fg() {
      ${pkgs.lib.getExe pkgs.tree} ${prefix}
      if read -r -p "Build agent?"
      then
        build
      fi
    }
  '';
}
