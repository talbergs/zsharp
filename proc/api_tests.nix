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

    sandbox() {
      rm -rf /tmp/phpunit-component-dir
      mkdir /tmp/phpunit-component-dir
      rm -rf /tmp/api-tests
      cp -R ${uiroot} /tmp/api-tests
      cd /tmp/api-tests

      nix run ${tool}#api_zabbix_conf_php -- \
        USER=http://127.0.0.1:${uiport}/ \
        DATABASE=${dbname} \
        PORT=${dbport} \
      > ./conf/zabbix.conf.php

      nix run ${tool}#api_bootstrap_php -- \
        PHPUNIT_URL=http://127.0.0.1:${uiport}/ \
        PHPUNIT_ERROR_LOG=/tmp/api_test_error.log \
        PHPUNIT_COMPONENT_DIR=$(fresh_dir /tmp/PHPUNIT_COMPONENT_DIR)/ \
      > ./bootstrap.php
    }

    picker() {
      ${pkgs.findutils}/bin/xargs -n 1 <<< "74 80 83 84" | ${getExe pkgs.fzf} --height=15
    }

    fg() {
      clear
      PHP_VER=''${phpver:-83}
      FILTER=''${FILTER:-}

      printf "$(tput setaf 2)%s\n%s\n%s$(tput sgr0)\n\n" \
        "1) Run?" \
        "2) Set php version? (current: $PHP_VER)" \
        "3) Set filter? (current: $FILTER)"
      read -N 1 -e -p "[1][2][3][4]>:" var

      case "$var" in
        2)
          phpver=$(picker)
          fg
        ;;
        3)
          read -e -p "filter>:" FILTER
          fg
        ;;
        1)
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

          nix run ${tool}#phpunit$PHP_VER -- $filter_arg \
            --bootstrap=/tmp/api-tests/bootstrap.php \
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
