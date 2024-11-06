{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    zjstatus.url = "github:dj95/zjstatus";
    system-db.url = "github:talbergs/system-db";
  };

  outputs =
    {
      self,
      nixpkgs,
      zjstatus,
      system-db,
    }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
      };
    in
    {

      packages.x86_64-linux.default = import ./default.nix { inherit pkgs system-db; };

    };
}
