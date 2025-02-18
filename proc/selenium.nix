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

    start_services() {
        selenium-server -log /tmp/selenium-server.log 2>/dev/null &
        echo "Started selenium server"

        PACKAGE="${tool}#phpv$PHP_VER"
        LOCALE_ARCHIVE=${pkgs.glibcLocalesUtf8.override {allLocales = true;}}/lib/locale/locale-archive \
        nix run $PACKAGE -- \
          -d date.timezone=Europe/Riga \
          -S 127.0.0.1:${uiport} 2>/dev/null &
        echo "Started php -S -S 127.0.0.1:${uiport}"
    }

    set_config() {
        sandbox:cd "${uiroot}" "selenium/${session}"
        echo "Copied ${uiroot} to $PWD"

        nix run ${tool}#selenium_bootstrap_php -- \
          PHPUNIT_URL=http://127.0.0.1:${uiport}/ \
          PHPUNIT_BASEDIR=$PWD \
          PHPUNIT_DATA_SOURCES_DIR=$PWD/tests/selenium/data/sources/ \
          PHPUNIT_DATA_DIR=$(tmp:new PHPUNIT_DATA_DIR) \
          PHPUNIT_COMPONENT_DIR=$(tmp:new PHPUNIT_COMPONENT_DIR)/ \
          PHPUNIT_REFERENCE_DIR=$(tmp:new PHPUNIT_REFERENCE_DIR) \
          PHPUNIT_SCREENSHOT_DIR=$(tmp:new PHPUNIT_SCREENSHOT_DIR) \
          PHPUNIT_SCREENSHOT_URL=$(tmp:new PHPUNIT_SCREENSHOT_URL) \
        > ./tests/bootstrap.php
        echo "Prepared $PWD/tests/bootstrap.php"

        nix run ${tool}#selenium_zabbix_conf_php -- \
          PORT=${dbport} \
          DATABASE=${dbname} \
          USER=${dbuser} \
        > ./conf/zabbix.conf.php
        echo "Prepared $PWD/conf/zabbix.conf.php"

        if [ -d ./tests/selenium/modules ]; then
          cp -r ./tests/selenium/modules/* ./modules
          echo "Added tests/selenium/modules"
        fi
        pwd

        cp -R ${tool}/php/selenium-vendor/vendor ./tests/vendor
        chmod 777 -R ./tests/vendor
        echo "Added tests/vendor"
    }

    PHP_VER=''${PHP_VER:-83}
    FILTER=''${FILTER:-$(state:get:selenium-filter ${session})}
    fg() {
      clear

      printf "$(tput setaf 2)%s\n%s\n%s\n%s$(tput sgr0)\n\n" \
        "1) Run?" \
        "2) Set php version? (current: $PHP_VER)" \
        "3) Set filter? (current: $FILTER)"
      read -N 1 -e -p "[1][2][3]>:" var

      case "$var" in
        1)
          set -euxo pipefail

          freshdb
          set_config
          start_services

          cd ./tests
          nix run ${tool}#phpunit$PHP_VER -- $FILTER \
            --stop-on-failure --stop-on-defect \
            --no-interaction --testdox \
            --bootstrap=./bootstrap.php \
            selenium/SeleniumTests.php
        ;;
        2)
          export PHP_VER=$(nix run ${tool}#php-picker)
          fg
        ;;
        3)
          read -e -p "filter>:" FILTER
          [ -z "$FILTER" ] && export FILTER= || export FILTER="--filter $FILTER"
          state:set:selenium-filter ${session} "$FILTER"
          fg
        ;;
        *)
          echo "Choose an option."
          fg
        ;;
      esac
    }
  '';
}
