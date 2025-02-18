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
  uiport = "3211";
in
with pkgs.lib;
pkgs.mkShell {
  packages = with pkgs; [
    less
    postgresql
  ];
  shellHook = ''
    source ${tool}/rtp.sh
    echo "List: $(rtp:db_scheme '${session}')"

    scheme="$(rtp:db_scheme '${session}')/postgresql.sql"

    freshdb() {
      echo 'drop database "${dbname}";' | psql --host=0.0.0.0 --port=${dbport} --dbname=postgres
      echo 'create database "${dbname}" encoding Unicode template template0;' | psql --host=0.0.0.0 --port=${dbport} --dbname=postgres
      echo "\i $scheme;" | psql --host=0.0.0.0 --port=${dbport} --dbname=${dbname}
      echo '\i ${uiroot}/tests/api_json/data/data_test.sql;' | psql --host=0.0.0.0 --port=${dbport} --dbname=${dbname}
    }

    set_config() {
      sandbox:cd "${uiroot}" "api-tests/${session}"
      echo "Copied ${uiroot} to $PWD"

      nix run ${tool}#api_bootstrap_php -- \
        PHPUNIT_URL=http://127.0.0.1:${uiport}/ \
        PHPUNIT_ERROR_LOG=/tmp/api_test_error.log \
        PHPUNIT_COMPONENT_DIR=$(tmp:new PHPUNIT_COMPONENT_DIR)/ \
      > ./tests/bootstrap.php
      echo "Prepared $PWD/tests/bootstrap.php"

      nix run ${tool}#api_zabbix_conf_php -- \
        PORT=${dbport} \
        DATABASE=${dbname} \
        USER=${dbuser} \
      > ./conf/zabbix.conf.php
      echo "Prepared $PWD/conf/zabbix.conf.php"
    }

    start_services() {
      PACKAGE="${tool}#phpv$PHP_VER"
      LOCALE_ARCHIVE=${pkgs.glibcLocalesUtf8.override {allLocales = true;}}/lib/locale/locale-archive \
      nix run $PACKAGE -- \
        -d date.timezone=Europe/Riga \
        -S 127.0.0.1:${uiport} 2>/dev/null &
      echo "Started php -S -S 127.0.0.1:${uiport}"
    }

    PHP_VER=''${PHP_VER:-83}
    FILTER=''${FILTER:-$(state:get:api-tests-filter ${session})}
    fg() {
      clear

      printf "$(tput setaf 2)%s\n%s\n%s$(tput sgr0)\n\n" \
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

          nix run ${tool}#phpunit$PHP_VER -- $FILTER \
            --bootstrap=./tests/bootstrap.php \
            ./tests/api_json/ApiJsonTests.php
        ;;
        2)
          export PHP_VER=$(nix run ${tool}#php-picker)
          fg
        ;;
        3)
          read -e -p "filter>:" FILTER
          [ -z "$FILTER" ] && export FILTER= || export FILTER="--filter $FILTER"
          state:set:api-tests-filter ${session} "$FILTER"
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
