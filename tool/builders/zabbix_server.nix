{ upstream ? <nixpkgs> }:
let
  pkgs = import upstream { };
in
pkgs.callPackage ./make_zabbix_build_env.nix
{
  inherit pkgs;
  env = "server";
  configureFlags = [
      "--enable-server"
  ];
}
