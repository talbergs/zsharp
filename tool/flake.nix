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
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; overlays = [ tg.outputs.overlay.${system} ]; };
    in
    {

      packages.x86_64-linux =
        {
          default = pkgs.hello;
          sass = pkgs.bundlerApp {
            pname = "sass";
            exes = [ "sass" ];
            gemdir = ./sass;
          };
        }

        // (import ./configs/default.nix { inherit pkgs; })
        // (import ./php/default.nix { inherit pkgs; phps = phps.packages.${system}; })
        // (import ./locale/default.nix { inherit pkgs; });
    };

}
