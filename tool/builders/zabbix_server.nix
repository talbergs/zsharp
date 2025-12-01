# you could try something like:
# export CFLAGS="-I/nix/store/b97gjl5zygaf6vzxsa1lf7jih8q4xi00-openssl-3.5.1-dev/include"
# 
# if it helps then certainly something is wrong on our side
# 
# or just specifly openssl include
# 
# I think we have problem with custom location that we need to check for include there
# 
# export CFLAGS="-I/nix/store/b97gjl5zygaf6vzxsa1lf7jih8q4xi00-openssl-3.5.1-dev/include"
# or whatever is your incldue location


{ upstream ? <nixpkgs> }:
let
  pkgs = import upstream { };
in
pkgs.callPackage ./make_zabbix_build_env.nix
{
  inherit pkgs;
  env = "server";
  configureFlags = [
      # "--with-net-snmp"
      "--enable-server"
      "--with-postgresql"
      "--with-libcurl"
      # "--with-openssl=${pkgs.openssl.dev}"
  ];
}
