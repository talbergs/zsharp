{ pkgs, ... }:
{

  get_translation_strings = import ./translation-strings-po.nix { inherit pkgs; };
  get_translation_strings_ts = import ./translation-strings-ts.nix { inherit pkgs; };

}
