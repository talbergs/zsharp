{ upstream ? <nixpkgs> }:
let
  pkgs = import upstream { };
in
pkgs.callPackage ./make_zabbix_build_env.nix
{
  inherit pkgs;
  env = "server";
  configureFlags = [
      "--with-postgresql"
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

      make dbschema
    }
  '';
}
