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
        "x86_64-darwin"
        "aarch64-darwin"
      ] (system: function (import nixpkgs { inherit system; }));

      tool = ./tool;
    in
    {
      packages = map_supported_systems (pkgs:
      let
        layout_template = import ./layout_template.nix { inherit pkgs tool nixpkgs; };
        layout_generator = import ./layout_generator.nix { inherit pkgs layout_template; };
      in {
        inherit layout_generator layout_template;
      } // {
        default = import ./default.nix { inherit pkgs layout_generator; };
      });
    };
}
