{
  tool,
  uiroot,
  scheme,
  dbport ? "5432",
  dbname,
  dbuser,
  upstream ? <nixpkgs>
}:
let
  pkgs = import upstream { };
  uiport = "8555";
in
with pkgs.lib;
pkgs.mkShell {
  packages = with pkgs; [
    less
    postgresql
  ];
  shellHook = ''
    freshdb() {
      echo 'drop database "${dbname}";' | psql --host=0.0.0.0 --port=${dbport} --dbname=postgres
      echo 'create database "${dbname}" encoding Unicode template template0;' | psql --host=0.0.0.0 --port=${dbport} --dbname=postgres
      echo '\i ${scheme};' | psql --host=0.0.0.0 --port=${dbport} --dbname=${dbname}
      echo '\i ${uiroot}/tests/api_json/data/data_test.sql;' | psql --host=0.0.0.0 --port=${dbport} --dbname=${dbname}
    }

    sandbox() {
      rm -rf /tmp/phpunit-component-dir
      mkdir /tmp/phpunit-component-dir
      rm -rf /tmp/api-tests
      cp -R ${uiroot} /tmp/api-tests
      cd /tmp/api-tests

      echo "<?php" > ./conf/zabbix.conf.php
      echo "\$DB['TYPE'] = ZBX_DB_POSTGRESQL;" >> ./conf/zabbix.conf.php
      echo "\$DB['SERVER'] = '127.0.0.1';" >> ./conf/zabbix.conf.php
      echo "\$DB['PORT'] = '${dbport}';" >> ./conf/zabbix.conf.php
      echo "\$DB['DATABASE'] = '${dbname}';" >> ./conf/zabbix.conf.php
      echo "\$DB['PASSWORD'] = null;" >> ./conf/zabbix.conf.php
      echo "\$DB['SCHEMA'] = null;" >> ./conf/zabbix.conf.php
      echo "\$DB['USER'] = '${dbuser}';" >> ./conf/zabbix.conf.php
      echo "\$DB['ENCRYPTION'] = false;" >> ./conf/zabbix.conf.php

      echo "<?php" > ./bootstrap.php
      echo "define('PHPUNIT_URL', 'http://127.0.0.1:${uiport}/');" >> ./bootstrap.php
      echo "define('PHPUNIT_LOGIN_NAME', 'Admin');" >> ./bootstrap.php
      echo "define('PHPUNIT_LOGIN_PWD', 'zabbix');" >> ./bootstrap.php
      echo "define('PHPUNIT_COMPONENT_DIR', '/tmp/phpunit-component-dir');" >> ./bootstrap.php
      echo "define('PHPUNIT_ERROR_LOG', '/tmp/api_test_error.log');" >> ./bootstrap.php

      (
        if [[ ! -e /tmp/phpunit-8.5.41.phar ]]
        then
          cd /tmp/
          ${pkgs.lib.getExe pkgs.wget} https://phar.phpunit.de/phpunit-8.5.41.phar
        fi
      )
    }

    picker() {
      ${pkgs.findutils}/bin/xargs -n 1 <<< "v74 v80 v83 v84" | ${getExe pkgs.fzf} --height=15
    }

    fg() {
      clear
      PHP_VER=''${phpver:-v83}
      FILTER=''${FILTER:-}

      printf "$(tput setaf 2)%s\n%s\n%s\n%s$(tput sgr0)\n\n" \
        "1) Set php version? (current: $PHP_VER)" \
        "2) Set filter? (current: $FILTER)" \
        "3) Clear filter?" \
        "4) Run?"
      read -N 1 -e -p "[1][2][3][4]>:" var

      case "$var" in
        1)
          phpver=$(picker)
          fg
        ;;
        2)
          read -e -p "filter>:" FILTER
          fg
        ;;
        3)
          FILTER=
          fg
        ;;
        4)
          freshdb
          sandbox
          PACKAGE="${tool}#php$PHP_VER"

          LOCALE_ARCHIVE=${pkgs.glibcLocalesUtf8.override {allLocales = true;}}/lib/locale/locale-archive \
          nix run $PACKAGE -- -S 127.0.0.1:${uiport} 2>/dev/null &

          filter_arg=
          if [ ! -z "$FILTER" ]
          then
            filter_arg="--filter $FILTER"
          fi

          nix run $PACKAGE -- \
            /tmp/phpunit-8.5.41.phar $filter_arg \
              --bootstrap /tmp/api-tests/bootstrap.php \
              --configuration=${uiroot}/tests/phpunit.xml \
          ./tests/api_json/ApiJsonTests.php
        ;;
        *)
          echo "Choose an option."
          fg
        ;;
      esac
    }
  '';
}
