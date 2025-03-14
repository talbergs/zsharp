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

    PHP_VER=''${PHP_VER:-83}
    fg() {
      clear

      [[ ! -e "${uiroot}/conf/zabbix.conf.php" ]] && mk_conf > ${uiroot}/conf/zabbix.conf.php
      [[ ! -z "${phpver}" ]] && build "${phpver}" && exit 0

      ${getExe pkgs.bat} ${uiroot}/conf/zabbix.conf.php

      printf "$(tput setaf 2)%s\n%s\n%s\n%s\n$(tput sgr0)\n\n" \
        "1) Run?" \
        "2) Reset config?" \
        "3) Edit config?" \
        "2) Set php version? (current: $PHP_VER)"
      read -N 1 -e -p "[1][2][3][4]>:" var

      case "$var" in
        1)
          cd "${uiroot}"
          nix run ${tool}#phpv''${PHP_VER}_serve -- ${uiport} /tmp/php.error.${dbname}.log
        ;;
        2)
          mk_conf > ${uiroot}/conf/zabbix.conf.php
          fg
        ;;
        3)
          if [ -z "$EDITOR" ]
          then

            printf "$(tput setaf 2)%s\n%s\n%s\n%s$(tput sgr0)\n\n" \
              "1) vim?" \
              "2) nano?" \
              "3) mocro? (Modern and intuitive terminal-based text editor)"
            read -N 1 -e -p "[1][2][3]>:" var

            case "$var" in
              1) ${getExe pkgs.neovim} "$DST/conf" ;;
              2) ${getExe pkgs.nano} "$DST/conf" ;;
              3) ${getExe pkgs.micro} "$DST/conf" ;;
              *) fg ;;
            esac

          else
            $EDITOR ${uiroot}/conf/zabbix.conf.php
          fi
          fg
        ;;
        4)
          export PHP_VER=$(nix run ${tool}#php-picker)
          fg
        ;;
      esac
    }
  '';
}
