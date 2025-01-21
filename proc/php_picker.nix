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
    build() {
      set +x
      echo "<?php" > ${uiroot}/conf/zabbix.conf.php
      echo "\$DB['TYPE'] = ZBX_DB_POSTGRESQL;" >> ${uiroot}/conf/zabbix.conf.php
      echo "\$DB['SERVER'] = 'localhost';" >> ${uiroot}/conf/zabbix.conf.php
      echo "\$DB['PORT'] = '${dbport}';" >> ${uiroot}/conf/zabbix.conf.php
      echo "\$DB['DATABASE'] = '${dbname}';" >> ${uiroot}/conf/zabbix.conf.php
      echo "\$DB['USER'] = '${dbuser}';" >> ${uiroot}/conf/zabbix.conf.php

      cd ${uiroot}

      PHP_VER="''${1:-v83}"
      PACKAGE="${tool}#php$PHP_VER"
      LOCALE_ARCHIVE=${pkgs.glibcLocalesUtf8.override {allLocales = true;}}/lib/locale/locale-archive \
      nix run "$PACKAGE" -- -S 0.0.0.0:${uiport} \
        -d memory_limit=4G \
        -d error_reporting=E_ALL \
        -d log_errors=On \
        -d error_log=/tmp/php.error.${dbname}.log
    }

    picker() {
      ${pkgs.findutils}/bin/xargs -n 1 <<< "v74 v80 v83 v84" | ${getExe pkgs.fzf} --height=15
    }

    fg() {
      if test -z "${phpver}"
      then
        build $(picker)
      elif read -r -p "Configure and run php ${phpver}? <c-d> to cancel"
      then
        build "${phpver}"
      else
        build $(picker)
      fi
    }
  '';
}
