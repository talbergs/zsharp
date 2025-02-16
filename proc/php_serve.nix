{ uiport, uiroot, dbuser, dbport, dbname, tool, phpver, upstream ? <nixpkgs> }:
let
  pkgs = import upstream { };
in
with pkgs.lib;
pkgs.mkShell {
  packages = with pkgs; [
    tailspin
  ];
  shellHook = ''
    mk_conf() {
      nix run ${tool}#zabbix_conf_php -- \
        PORT="${dbport}" \
        DATABASE="${dbname}" \
        USER="${dbuser}"
    }

    serve() {
      nix run ${tool}#php$1_serve --  ${uiport} /tmp/php.error.${dbname}.log
    }

    build() {
      cd "${uiroot}" && serve "$1" || exit 2
    }

    PHP_VER=''${PHP_VER:-83}
    fg() {
      clear

      [[ ! -e "${uiroot}/conf/zabbix.conf.php" ]] && mk_conf > ${uiroot}/conf/zabbix.conf.php
      [[ ! -z "${phpver}" ]] && build "${phpver}" && exit 0

      ${getExe pkgs.bat} ${uiroot}/conf/zabbix.conf.php

      printf "$(tput setaf 2)%s\n%s\n$(tput sgr0)\n\n" \
        "1) Run?" \
        "2) Set php version? (current: ''${PHP_VER:-v83})"
      read -N 1 -e -p "[1][2]>:" var

      case "$var" in
        1)
          build ''${PHP_VER:-v83}
        ;;
        2)
          export PHP_VER=$(nix run ${tool}#php-picker)
          fg
        ;;
      esac
    }
  '';
}
