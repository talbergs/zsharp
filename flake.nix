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
      tool = ./tool;
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      layout_template = import ./layout_template.nix { inherit pkgs tool nixpkgs; };
      layout_generator = import ./layout_generator.nix { inherit pkgs layout_template; };
    in
    {

      packages.x86_64-linux.default = import ./default.nix { inherit pkgs layout_generator; };
      packages.x86_64-linux.layout_generator = layout_generator;
      packages.x86_64-linux.layout_template = layout_template;

    };
}
