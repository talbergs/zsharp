{ pkgs
, tool # path to nix store that contains flake of tools - enables lazy build
, nixpkgs # path to nix store
, ... }:
pkgs.writeTextFile {
  name = "zsharp.kdl";
  text = ''
    layout {
        default_tab_template {
            pane size=1 borderless=true {
                plugin location="zellij:tab-bar"
            }
            children
            pane size=2 borderless=true {
                plugin location="zellij:status-bar"
            }
        }

        tab name="Builders:C" split_direction="vertical" cwd="{{ $SOURCES }}" {
            pane stacked=true split_direction="horizontal" {
                pane command="nix-shell" name="Server" {
                    args \
                        "--run" "fg" \
                        "--argstr" "tool" "${tool}" \
                        "--argstr" "session" "{{ $SESSION }}" \
                        "--argstr" "upstream" "${nixpkgs}" \
                        "--include" "nixpkgs=${nixpkgs}" \
                        "${./proc/zabbix_server.nix}"
                }

                pane command="nix-shell" name="Proxy" {
                    args \
                        "--run" "fg" \
                        "--argstr" "tool" "${tool}" \
                        "--argstr" "session" "{{ $SESSION }}" \
                        "--argstr" "upstream" "${nixpkgs}" \
                        "--include" "nixpkgs=${nixpkgs}" \
                        "${./proc/zabbix_proxy.nix}"
                }
                pane command="nix-shell" name="Agent2" {
                    args \
                        "--run" "fg" \
                        "--argstr" "upstream" "${nixpkgs}" \
                        "--argstr" "tool" "${tool}" \
                        "--argstr" "session" "{{ $SESSION }}" \
                        "${./proc/zabbix_agents.nix}"
                }
                pane command="nix-shell" name="Webservice" {
                    args \
                        "--run" "fg" \
                        "--argstr" "upstream" "${nixpkgs}" \
                        "--argstr" "tool" "${tool}" \
                        "--argstr" "session" "{{ $SESSION }}" \
                        "${./proc/zabbix_webservice.nix}"
                }
            }
        }

        tab name="Runners:C" split_direction="vertical" cwd="{{ $SOURCES }}" {
            pane stacked=true split_direction="horizontal" {
                pane command="nix-shell" name="Server process" size="30%" {
                    args \
                        "--run" "fg" \
                        "--argstr" "session" "{{ $SESSION }}" \
                        "--argstr" "dbuser" "{{ $DB_USER }}" \
                        "--argstr" "dbname" "{{ $DB_NAME }}" \
                        "--argstr" "upstream" "${nixpkgs}" \
                        "--include" "nixpkgs=${nixpkgs}" \
                        "--argstr" "tool" "${tool}" \
                        "${./proc/zabbix_server_run.nix}"
                }
                pane command="nix-shell" name="Server logs" {
                    args \
                        "--run" "logfile=$(rtp:dst:server {{ $SESSION }})/log;colorizer:c" \
                        "--argstr" "upstream" "${nixpkgs}" \
                        "--argstr" "tool" "${tool}" \
                    "${./proc/grc.nix}"
                }
                pane command="nix-shell" name="Agent2 process" size="30%" {
                    args \
                        "--run" "fg" \
                        "--argstr" "tool" "${tool}" \
                        "--argstr" "session" "{{ $SESSION }}" \
                        "--argstr" "upstream" "${nixpkgs}" \
                        "${./proc/zabbix_agent2_run.nix}"
                }
                pane command="nix-shell" name="Agent2 logs" {
                    args \
                        "--run" "logfile=$(rtp:dst:agents {{ $SESSION }})/log;colorizer:c" \
                        "--argstr" "upstream" "${nixpkgs}" \
                        "--argstr" "tool" "${tool}" \
                    "${./proc/grc.nix}"
                }
                pane command="nix-shell" name="Proxy process" size="30%" {
                    args \
                        "--run" "fg" \
                        "--argstr" "tool" "${tool}" \
                        "--argstr" "session" "{{ $SESSION }}" \
                        "--argstr" "dbname" "{{ $DB_NAME }}" \
                        "--argstr" "upstream" "${nixpkgs}" \
                        "${./proc/zabbix_proxy_run.nix}"
                }
                pane command="nix-shell" name="Proxy logs" {
                    args \
                        "--run" "logfile=$(rtp:dst:proxy {{ $SESSION }})/log;colorizer:c" \
                        "--argstr" "upstream" "${nixpkgs}" \
                        "--argstr" "tool" "${tool}" \
                    "${./proc/grc.nix}"
                }
                pane command="nix-shell" name="Webservice process" size="30%" {
                    args \
                        "--run" "fg" \
                        "--argstr" "tool" "${tool}" \
                        "--argstr" "session" "{{ $SESSION }}" \
                        "--argstr" "upstream" "${nixpkgs}" \
                        "${./proc/zabbix_webservice_run.nix}"
                }
                pane command="nix-shell" name="Webservice logs" {
                    args \
                        "--run" "logfile=$(rtp:dst:webservice {{ $SESSION }})/log;colorizer:c" \
                        "--argstr" "upstream" "${nixpkgs}" \
                        "--argstr" "tool" "${tool}" \
                    "${./proc/grc.nix}"
                }
            }
        }

        tab name="Database" split_direction="vertical" cwd="{{ $SOURCES }}" {
            pane stacked=true split_direction="horizontal" {
                pane command="nix-shell" name="Client on {{ $DB_NAME }}" {
                    args \
                        "--run" "fg" \
                        "--argstr" "dbport" "{{ $DB_PORT }}" \
                        "--argstr" "dbname" "{{ $DB_NAME }}" \
                        "--argstr" "upstream" "${nixpkgs}" \
                         "--include" "nixpkgs=${nixpkgs}" \
                        "${./proc/postgres-cli.nix}"
                }

                pane cwd="{{ $SOURCES }}" command="nix-shell" name="Scheme on {{ $DB_NAME }}" {
                    args \
                        "--run" "fg" \
                        "--argstr" "dbport" "{{ $DB_PORT }}" \
                        "--argstr" "dbname" "{{ $DB_NAME }}" \
                        "--argstr" "session" "{{ $SESSION }}" \
                        "--argstr" "tool" "${tool}" \
                        "--argstr" "upstream" "${nixpkgs}" \
                        "${./proc/postgres-apply.nix}"
                }

                pane command="nix-shell" name="Cluster" {
                    args \
                        "--run" "fg" \
                        "--argstr" "dbport" "{{ $DB_PORT }}" \
                        "--argstr" "pgdata" "{{ $DB_ROOT }}" \
                        "--argstr" "upstream" "${nixpkgs}" \
                        "--include" "nixpkgs=${nixpkgs}" \
                        "${./proc/postgres.nix}"
                }

                pane cwd="{{ $SOURCES }}" command="nix-shell" name="Scheme" {
                    args \
                        "--run" "fg" \
                        "--argstr" "upstream" "${nixpkgs}" \
                        "--argstr" "tool" "${tool}" \
                        "--argstr" "session" "{{ $SESSION }}" \
                        "${./proc/zabbix_scheme.nix}"
                }
            }
        }

        tab name="Runners:WEB" split_direction="vertical" cwd="{{ $SOURCES }}/ui" {
            pane stacked=true split_direction="horizontal" {
                pane  size="30%" {
                    name "PHP ({{ $PHP_VER }}) at port {{ $UI_PORT }}"
                    command "nix-shell"
                    args \
                        "--run" "fg" \
                        "--argstr" "uiroot" "{{ $UI_ROOT }}" \
                        "--argstr" "uiport" "{{ $UI_PORT }}" \
                        "--argstr" "dbuser" "{{ $DB_USER }}" \
                        "--argstr" "dbport" "{{ $DB_PORT }}" \
                        "--argstr" "dbname" "{{ $DB_NAME }}" \
                        "--argstr" "phpver" "{{ $PHP_VER }}" \
                        "--argstr" "tool" "${tool}" \
                        "--argstr" "upstream" "${nixpkgs}" \
                        "--include" "nixpkgs=${nixpkgs}" \
                    "${./proc/php_serve.nix}"
                }

                pane command="nix-shell" name="PHP:logs-colorized" {
                    args \
                        "--run" "logfile=/tmp/php.error.{{ $SESSION }}.log;colorizer:php" \
                        "--argstr" "upstream" "${nixpkgs}" \
                        "--argstr" "tool" "${tool}" \
                    "${./proc/grc.nix}"
                }

                pane command="nix-shell" name="Symfony var dumper" {
                    args \
                        "--run" "fg" \
                        "--argstr" "tool" "${tool}" \
                        "--argstr" "upstream" "${nixpkgs}" \
                        "--include" "nixpkgs=${nixpkgs}" \
                        "${./proc/php_svd.nix}"
                }
            }
        }

        tab name="Builders:WEB" split_direction="vertical" cwd="{{ $SOURCES }}" {
            pane split_direction="horizontal" {
                pane command="nix-shell" name="SASS build" {
                    args \
                        "--run" "fg" \
                        "--argstr" "tool" "${tool}" \
                        "--argstr" "upstream" "${nixpkgs}" \
                        "--include" "nixpkgs=${nixpkgs}" \
                        "${./proc/zabbix_sass.nix}"
                }

                pane command="nix-shell" name="diff-locale-strings" {
                    args \
                        "--run" "fg" \
                        "--argstr" "upstream" "${nixpkgs}" \
                        "--argstr" "tool" "${tool}" \
                        "--include" "nixpkgs=${nixpkgs}" \
                        "${./proc/check_strings.nix}"
                }
            }

        }

        tab name="Tests" split_direction="vertical" cwd="{{ $SOURCES }}" {
            pane stacked=true split_direction="horizontal" {
                pane command="nix-shell" name="phpunit on php 7.4 (for zabbix 6.0+)" {
                    args \
                        "--run" "fg" \
                        "--argstr" "tool" "${tool}" \
                        "--argstr" "uiroot" "{{ $UI_ROOT }}" \
                        "--argstr" "phpver" "74" \
                        "--argstr" "upstream" "${nixpkgs}" \
                        "--include" "nixpkgs=${nixpkgs}" \
                        "${./proc/phpunit_run.nix}"
                }
                pane command="nix-shell" name="phpunit on php 8.0 (for zabbix 7.0+)" {
                    args \
                        "--run" "fg" \
                        "--argstr" "tool" "${tool}" \
                        "--argstr" "uiroot" "{{ $UI_ROOT }}" \
                        "--argstr" "phpver" "80" \
                        "--argstr" "upstream" "${nixpkgs}" \
                        "--include" "nixpkgs=${nixpkgs}" \
                        "${./proc/phpunit_run.nix}"
                }
                pane command="nix-shell" name="phpunit on php 8.3 (for zabbix ~)" {
                    args \
                        "--run" "fg" \
                        "--argstr" "tool" "${tool}" \
                        "--argstr" "uiroot" "{{ $UI_ROOT }}" \
                        "--argstr" "phpver" "83" \
                        "--argstr" "upstream" "${nixpkgs}" \
                        "--include" "nixpkgs=${nixpkgs}" \
                        "${./proc/phpunit_run.nix}"
                }
                pane command="nix-shell" name="phpunit on php 8.4 (for zabbix ^)" {
                    args \
                        "--run" "fg" \
                        "--argstr" "tool" "${tool}" \
                        "--argstr" "uiroot" "{{ $UI_ROOT }}" \
                        "--argstr" "phpver" "84" \
                        "--argstr" "upstream" "${nixpkgs}" \
                        "--include" "nixpkgs=${nixpkgs}" \
                        "${./proc/phpunit_run.nix}"
                }
                pane command="nix-shell" name="* API tests" {
                    args \
                        "--run" "fg" \
                        "--argstr" "tool" "${tool}" \
                        "--argstr" "session" "{{ $SESSION }}" \
                        "--argstr" "uiroot" "{{ $UI_ROOT }}" \
                        "--argstr" "dbport" "{{ $DB_PORT }}" \
                        "--argstr" "dbname" "{{ $DB_NAME }}-test-api" \
                        "--argstr" "dbuser" "{{ $DB_USER }}" \
                        "--argstr" "upstream" "${nixpkgs}" \
                        "${./proc/api_tests.nix}"
                }
                pane command="nix-shell" name="* Selenium tests" {
                    args \
                        "--run" "fg" \
                        "--argstr" "tool" "${tool}" \
                        "--argstr" "session" "{{ $SESSION }}" \
                        "--argstr" "uiroot" "{{ $UI_ROOT }}" \
                        "--argstr" "dbport" "{{ $DB_PORT }}" \
                        "--argstr" "dbname" "{{ $DB_NAME }}-test-selenium" \
                        "--argstr" "dbuser" "{{ $DB_USER }}" \
                        "--argstr" "upstream" "${nixpkgs}" \
                        "${./proc/selenium.nix}"
                }
                pane command="nix-shell" name="* Integration tests (api tests)" {
                    args \
                        "--run" "fg" \
                        "--argstr" "tool" "${tool}" \
                        "--argstr" "session" "{{ $SESSION }}" \
                        "--argstr" "uiroot" "{{ $UI_ROOT }}" \
                        "--argstr" "dbport" "{{ $DB_PORT }}" \
                        "--argstr" "dbname" "{{ $DB_NAME }}-test-api" \
                        "--argstr" "dbuser" "{{ $DB_USER }}" \
                        "--argstr" "upstream" "${nixpkgs}" \
                        "${./proc/api_tests.nix}"
                }
            }
        }

        tab name="Static analysis" split_direction="vertical" cwd="{{ $SOURCES }}" {
            pane command="nix-shell" name="Coding style" {
                args \
                    "--run" "fg" \
                    "--argstr" "session" "{{ $SESSION }}" \
                    "--argstr" "tool" "${tool}" \
                    "--argstr" "upstream" "${nixpkgs}" \
                    "${./proc/check_coding_style.nix}"
            }
        }
    }
  '';
}
# vim: ts=4 sw=4
