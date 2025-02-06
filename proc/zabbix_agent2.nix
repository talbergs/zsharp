{ tool, upstream ? <nixpkgs> }:
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
    source ${tool}/rtp.sh

    build() {
      ./bootstrap.sh
      ./configure \
        --prefix="$(rtp:agent)" \
        --with-libpcre2=$(dirname $(which pcre2-config))/.. \
        --enable-agent2

      make clean -j6
      make install -j6

      ${pkgs.lib.getExe pkgs.tree} "$(rtp:agent)"
    }

    fg() {
      ${pkgs.lib.getExe pkgs.tree} "$(rtp:agent)"
      if read -r -p "Build agent2?"
      then
        build
      fi
    }
  '';
}
