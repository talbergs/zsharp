{ pkgs, phps, ... }:
let
  dev = ./dev-runtime;
  common = {
    extensions = ({ enabled, all }: enabled ++ (with all; [ xdebug spx ]));
    extraConfig = ''
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
in {
  phpv74 = phps.php74.buildEnv common;
  phpv80 = phps.php80.buildEnv common;
  phpv83 = phps.php83.buildEnv common;
  phpv84 = phps.php84.buildEnv common;
  phpsvd = pkgs.writeShellApplication {
    name = "_";
    runtimeInputs = [ (phps.php83.buildEnv common) ];
    text = ''
      LOCALE_ARCHIVE=${
        pkgs.glibcLocalesUtf8.override { allLocales = true; }
      }/lib/locale/locale-archive \
      ${dev}/vendor/bin/var-dump-server "$@"
    '';
  };
}
