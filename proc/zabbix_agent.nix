{ tool, upstream ? <nixpkgs> }:
let
  pkgs = import upstream { };
in
with pkgs.lib;
pkgs.mkShell {
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
    source ${tool}/rtp.sh

    build() {
      ./bootstrap.sh
      ./configure \
        --prefix="$(rtp:agent)" \
        --with-libpcre2=$(dirname $(which pcre2-config))/.. \
        --enable-agent

      make clean -j6
      make install -j6
    }

    fg() {
      echo "List: $(rtp:agent)"
      ${getExe pkgs.tree} "$(rtp:agent)"

      if read -r -p "Build agent?"
      then
        build
      fi

      fg
    }
  '';
}
