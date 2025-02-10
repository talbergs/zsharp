{ pkgs ? import <nixpkgs> {}, ... }:
let
  rtp = ../rtp.sh;
  ri = with pkgs; [
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
    coreutils
    gnugrep
    gnused
    binutils
  ];

in
 
with pkgs.lib; pkgs.writeShellScriptBin "build_zabbix_server" ''
  set -x
  dst="$DST"
  src="$SRC"
  pcre2="${getExe' pkgs.pcre2 "pcre2-config"}"
  echo "Prefix/dst: $dst"
  echo "Sources: $src"
  echo "Libs: $pcre2"

  export PATH=${makeBinPath ri}
  source ${rtp}
  sandbox:cd "$src" "build_type.build_number"

  ./bootstrap.sh

  ./configure \
    --enable-server \
    --with-postgresql \
    --prefix="$dst" \
    --with-zlib=${pkgs.zlib} \
    --with-libevent \
    --with-libpcre2="$(dirname "$pcre2")/.."

  make clean -j6
  make install -j6
''
