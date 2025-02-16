{
  description = "Set of tools locked to versions.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    phps.url = "github:fossar/nix-phps";
    tg.url = "github:BrianHicks/tree-grepper/8821969c973617874b39042b4abc0f545236b36d";
  };

  outputs =
    {
      nixpkgs,
      phps,
      tg,
      ...
    }:
    let
      map_supported_systems = function: nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ] (system: function ({ inherit system; } // (import nixpkgs { inherit system; overlays = [ tg.outputs.overlay.${system} ]; })));
    in
    {

      packages = map_supported_systems (pkgs:
        {
          sass = pkgs.bundlerApp {
            pname = "sass";
            exes = [ "sass" ];
            gemdir = ./sass;
          };
          php-picker = import ./util/php-picker.nix { inherit pkgs; };
        }

        // (import ./builders/default.nix { inherit pkgs; })
        // (import ./configs/default.nix { inherit pkgs; })
        // (import ./php/default.nix { inherit pkgs phps; })
        // (import ./locale/default.nix { inherit pkgs; })
      );
    };

}
