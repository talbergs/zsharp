{
  description = "The tool belt";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    {
      nixpkgs,
      ...
    }:
    let
      map_supported_systems = function: nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darvin"
        "aarch64-darvin"
      ] (system: function nixpkgs.legacyPackages.${system});

      tool = ./tool;
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      layout_template = import ./layout_template.nix { inherit pkgs tool nixpkgs; };
      layout_generator = import ./layout_generator.nix { inherit pkgs layout_template; };
    in
    {
      packages = map_supported_systems (pkgs: {
        default = import ./default.nix { inherit pkgs layout_generator; };
        layout_generator = layout_generator;
        layout_template = layout_template;
      });
    };
}
