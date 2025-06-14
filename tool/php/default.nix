{ pkgs, phps, ... }:
with pkgs.lib;
let
  _phps = phps.packages.${pkgs.system};
  phpunit_phar = ./phpunit-8.5.41.phar;
  dev = ./dev-runtime;
  common = {

    # extensions = ({ enabled, all }: let
    #   enabledNoSSL = builtins.filter (e: e != all.openssl) enabled;
    # in enabledNoSSL ++ (with all; [ xdebug spx ]));

    extensions = ({ enabled, all }: enabled ++ (with all; [ xdebug spx ]));

    # extensions = ({ enabled, all }: (with all; [
    #   mysqli
    #   pgsql
    #   bcmath
    #   mbstring
    #   sockets
    #   gd
    #   xmlwriter
    #   xmlreader
    #   ctype
    #   session
    #   ldap
    #   gettext
    #   curl
    # ]));

    extraConfig = ''
      max_execution_time = 300
      post_max_size = 16M

      ;;
      ;; add &XDEBUG_SESSION_START=1 query parameter
      ;;
      xdebug.start_with_request = trigger
      xdebug.client_host = localhost
      xdebug.mode = develop,debug
      xdebug.discover_client_host = 1

      ;;
      ;; http://localhost:8081/any.php?SPX_KEY=dev&SPX_UI_URI=/
      ;;
      spx.http_enabled=1
      spx.http_key="dev"
      spx.http_ip_whitelist="127.0.0.1"

      auto_prepend_file=${dev}/debug.php
    '';
  };
  build_phpunit = php: pkgs.writeShellApplication {
    name = "phpunit";
    runtimeInputs = [ php ];
    text = ''
      ${getExe pkgs.banner} "PHP: $(${getExe php} -r 'echo PHP_VERSION;')"
      ${getExe php} ${phpunit_phar} "$@"
    '';
  };
  build_php = buildEnv:
    pkgs.writeShellApplication {
    name = "php";
    text = ''
      LOCALE_ARCHIVE=${
        pkgs.glibcLocalesUtf8.override { allLocales = true; }
      }/lib/locale/locale-archive \
      ${getExe (buildEnv common)} "$@"
    '';
  };
  build_php_server = php: pkgs.writeShellScriptBin "php_serve" ''
    echo "Logs: $2; Port: $1"
    ${getExe php} \
        -d date.timezone=Europe/Riga \
        -d memory_limit=4G \
        -d error_reporting=E_ALL \
        -d log_errors=On \
        -d error_log=$2 \
        -S 127.0.0.1:$1
  '';
in rec {
  phpv56_serve = build_php_server phpv56;
  phpv74_serve = build_php_server phpv74;
  phpv80_serve = build_php_server phpv80;
  phpv81_serve = build_php_server phpv81;
  phpv83_serve = build_php_server phpv83;
  phpv84_serve = build_php_server phpv84;

  phpunit56 = build_phpunit phpv56;
  phpunit74 = build_phpunit phpv74;
  phpunit80 = build_phpunit phpv80;
  phpunit81 = build_phpunit phpv81;
  phpunit83 = build_phpunit phpv83;
  phpunit84 = build_phpunit phpv84;

  phpv56 = build_php _phps.php56.buildEnv;
  phpv74 = build_php _phps.php74.buildEnv;
  phpv80 = build_php _phps.php80.buildEnv;
  phpv81 = build_php _phps.php81.buildEnv;
  phpv83 = build_php _phps.php83.buildEnv;
  phpv84 = build_php _phps.php84.buildEnv;

  phpsvd = pkgs.writeShellApplication {
    name = "var-dump-server";
    runtimeInputs = [ phpv83 ];
    text = ''
      ${dev}/vendor/bin/var-dump-server "$@"
    '';
  };
}
