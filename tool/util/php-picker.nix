{ pkgs }:
with pkgs.lib;
pkgs.writeShellScriptBin "php-picker" ''
    ${pkgs.findutils}/bin/xargs -n 1 <<< "74 80 81 83 84" \
      | ${getExe pkgs.fzf} --height=15 \
      || echo -n 83
''
