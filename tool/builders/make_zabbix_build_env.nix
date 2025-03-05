{ pkgs
, env ? "default"
, configureFlags ? []
, extraConfig ? ""
}:
with pkgs.lib;
let
  configureFlagsStr = builtins.concatStringsSep " " configureFlags;
  rtp = ../rtp.sh;
in
pkgs.mkShell
{
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
    sqlite
  ];
  shellHook = ''
    set -o nounset
    dst="$DST"
    src="$SRC"

    set -x

    ${extraConfig}

    build() {
      cd "$src"
      source ${rtp}
      sandbox:cd "$src" "$(basename $src)/${env}"
      ./bootstrap.sh
      ./configure \
        ${configureFlagsStr} \
        --prefix="$dst" \
        --with-zlib=${pkgs.zlib} \
        --with-libevent \
        --with-libpcre2=$(dirname $(which pcre2-config))/..

      make clean -j6
      make install -j6
    }

    fg() {
      clear
      ${getExe pkgs.tree} "$dst"
      export ZABBIX_REVISION=$(${getExe pkgs.git} rev-parse HEAD)
      if read -r -p "Build ${env} from sources '$src'?"
      then
        build
      fi
    }
  '';
}
