{
  session,
  tool,
  uiroot,
  dbport ? "5432",
  dbname,
  dbuser,
  upstream,
}:
let
  pkgs = import upstream { };
  uiport = "3210";
in
with pkgs.lib;
pkgs.mkShell {
  packages = with pkgs; [
    less
    postgresql
    selenium-server-standalone
    chromium
  ];
  shellHook = ''
    source ${tool}/rtp.sh
    echo "List: $(rtp:db_scheme '${session}')"

    scheme="$(rtp:db_scheme '${session}')/postgresql.sql"

    freshdb() {
      echo 'drop database "${dbname}";' | psql --host=0.0.0.0 --port=${dbport} --dbname=postgres
      echo 'create database "${dbname}" encoding Unicode template template0;' | psql --host=0.0.0.0 --port=${dbport} --dbname=postgres
      echo "\i $scheme;" | psql --host=0.0.0.0 --port=${dbport} --dbname=${dbname}
      echo '\i ${uiroot}/tests/selenium/data/data_test.sql;' | psql --host=0.0.0.0 --port=${dbport} --dbname=${dbname}
    }

    fresh_dir() {
      rm -rf "$1"
      mkdir -p "$1"
      echo -n "$1"
    }

    sandbox() {
      FILTER=
      if [ ! -z "$1" ]
      then
        FILTER="--filter $1"
      fi

      if [ -d /tmp/xselenium-ui ]
      then
        rm -rf /tmp/xselenium-ui
      fi

      cp -R ./ui /tmp/xselenium-ui
      cd /tmp/xselenium-ui

      PHP_VER=v83
      PACKAGE="${tool}#php$PHP_VER"
      LOCALE_ARCHIVE=${pkgs.glibcLocalesUtf8.override {allLocales = true;}}/lib/locale/locale-archive \
      nix run $PACKAGE -- \
        -d date.timezone=Europe/Riga \
        -S 127.0.0.1:${uiport} 2>/dev/null &

      nix run ${tool}#selenium_zabbix_conf_php -- \
        PORT=${dbport} \
        DATABASE=${dbname} \
        USER=${dbuser} \
      > ./conf/zabbix.conf.php

      nix run ${tool}#selenium_bootstrap_php -- \
        PHPUNIT_URL=http://127.0.0.1:${uiport}/ \
        PHPUNIT_BASEDIR=/tmp/xselenium-ui \
        PHPUNIT_DATA_SOURCES_DIR=/tmp/xselenium-ui/tests/selenium/data/sources/ \
        PHPUNIT_DATA_DIR=$(fresh_dir /tmp/PHPUNIT_DATA_DIR) \
        PHPUNIT_COMPONENT_DIR=$(fresh_dir /tmp/PHPUNIT_COMPONENT_DIR)/ \
        PHPUNIT_REFERENCE_DIR=/tmp/screenshots-reference \
        PHPUNIT_SCREENSHOT_DIR=/tmp/screenshots \
        PHPUNIT_SCREENSHOT_URL=/tmp/screenshots-reference/ \
      > ./tests/bootstrap.php

      if [ -d ./tests/selenium/modules ]; then
        cp -r ./tests/selenium/modules/* ./modules
      fi

      echo "{
        \"require-dev\": {
        \"phpunit/phpunit-selenium\": \"^3.0\",
        \"php-webdriver/webdriver\": \"^1.11\"
        }
      }" > ./tests/composer.json

      (cd ./tests; ${getExe pkgs.phpPackages.composer} install)
   
      if [[ ! -e /tmp/phpunit-8.5.41.phar ]]
      then
        (
          cd /tmp
          ${pkgs.lib.getExe pkgs.wget} https://phar.phpunit.de/phpunit-8.5.41.phar
        )
      fi

      cd ./tests
      export XDEBUG_CONFIG="idekey=netbeans-xdebug"

      ${getExe pkgs.php} /tmp/phpunit-8.5.41.phar $FILTER \
        --bootstrap=bootstrap.php \
        --testdox \
        --configuration=./phpunit.xml \
        selenium/SeleniumTests.php
    }

    picker() {
      ${pkgs.findutils}/bin/xargs -n 1 <<< "v74 v80 v83 v84" | ${getExe pkgs.fzf} --height=15
    }

    fg() {
      clear
      PHP_VER=''${phpver:-v83}
      FILTER=''${FILTER:-}

      printf "$(tput setaf 2)%s\n%s\n%s\n%s\n%s$(tput sgr0)\n\n" \
        "1) Set php version? (current: $PHP_VER)" \
        "2) Set filter? (current: $FILTER)" \
        "3) Clear filter?" \
        "4) Run?"
        "5) Run manual?"
      read -N 1 -e -p "[1][2][3][4][5]>:" var

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

          selenium-server 2>/dev/null &

          sandbox "$FILTER"
        ;;
        4)
          freshdb

          selenium-server 2>/dev/null &
        ;;
        *)
          echo "Choose an option."
          fg
        ;;
      esac
    }
  '';
}
