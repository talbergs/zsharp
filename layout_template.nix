{ pkgs
, tool # path to nix store that contains flake of tools - enables lazy build
, nixpkgs # path to nix store
, ... }:
pkgs.writeTextFile {
  name = "zashboard.kdl";
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
            pane split_direction="horizontal" {
                pane command="nix-shell" name="Server" {
                    args \
                        "--run" "fg" \
                        "--argstr" "prefix" "{{ $SOURCES }}/zashboard/server" \
                        "--argstr" "upstream" "${nixpkgs}" \
                        "--include" "nixpkgs=${nixpkgs}" \
                        "${./proc/zabbix_server.nix}"
                }

                pane command="nix-shell" name="Proxy" {
                    args \
                        "--run" "fg" \
                        "--argstr" "prefix" "{{ $SOURCES }}/zashboard/proxy" \
                        "--argstr" "upstream" "${nixpkgs}" \
                        "--include" "nixpkgs=${nixpkgs}" \
                        "${./proc/zabbix_proxy.nix}"
                }
            }

            pane split_direction="horizontal" {
                pane command="nix-shell" name="Agent2" {
                    args \
                        "--run" "fg" \
                        "--argstr" "prefix" "{{ $SOURCES }}/zashboard/agent2" \
                        "--argstr" "upstream" "${nixpkgs}" \
                        "--include" "nixpkgs=${nixpkgs}" \
                        "${./proc/zabbix_agent2.nix}"
                }

                pane command="nix-shell" name="Agent" {
                    args \
                        "--run" "fg" \
                        "--argstr" "prefix" "{{ $SOURCES }}/zashboard/agent" \
                        "--argstr" "upstream" "${nixpkgs}" \
                        "--include" "nixpkgs=${nixpkgs}" \
                        "${./proc/zabbix_agent.nix}"
                }
            }
        }

        tab name="Runners:C" split_direction="vertical" cwd="{{ $SOURCES }}" {
            pane split_direction="horizontal" {
                pane command="nix-shell" name="Server process" size="30%" {
                    args \
                        "--run" "fg" \
                        "--argstr" "prefix" "{{ $SOURCES }}/zashboard/server" \
                        "--argstr" "dbuser" "{{ $DB_USER }}" \
                        "--argstr" "dbname" "{{ $DB_NAME }}" \
                        "--argstr" "upstream" "${nixpkgs}" \
                        "--include" "nixpkgs=${nixpkgs}" \
                        "${./proc/zabbix_server_run.nix}"
                }
                pane command="tail" borderless=true name="Server logs" {
                    args \
                        "-F" "{{ $SOURCES }}/zashboard/server/zabbix_server.log"
                }
            }
            pane split_direction="horizontal" {
                pane command="nix-shell" name="Agent2 process" size="30%" {
                    args \
                        "--run" "fg" \
                        "--argstr" "prefix" "{{ $SOURCES }}/zashboard/agent2" \
                        "--argstr" "upstream" "${nixpkgs}" \
                        "--include" "nixpkgs=${nixpkgs}" \
                        "${./proc/zabbix_agent2_run.nix}"
                }
                pane command="tail" borderless=true name="Agent2 logs" {
                    args \
                        "-F" "{{ $SOURCES }}/zashboard/agent2/zabbix_agent2.log"
                }
            }
        }

        tab name="Database" split_direction="vertical" cwd="{{ $SOURCES }}" {
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
                    "--argstr" "scheme" "{{ $SOURCES }}/zashboard/dbschemes/postgresql.sql" \
                    "--argstr" "upstream" "${nixpkgs}" \
                    "--include" "nixpkgs=${nixpkgs}" \
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
                    "--argstr" "prefix" "{{ $SOURCES }}/zashboard/dbschemes" \
                    "--argstr" "upstream" "${nixpkgs}" \
                    "--include" "nixpkgs=${nixpkgs}" \
                    "${./proc/zabbix_scheme.nix}"
            }
        }

        tab name="Runners:WEB" split_direction="vertical" cwd="{{ $SOURCES }}/ui" {
            pane split_direction="horizontal" {
                pane {
                    name "PHP ({{ $PHP_VER }})"
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
                    "${./proc/php_picker.nix}"
                }

                pane command="nix-shell" name="PHP:logs-colorized" {
                    args \
                        "--run" "colorizer:php" \
                        "--argstr" "logfile" "/tmp/php.error.{{ $DB_NAME }}.log" \
                        "--argstr" "upstream" "${nixpkgs}" \
                        "--include" "nixpkgs=${nixpkgs}" \
                    "${./proc/grc.nix}"
                }
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
                        "--argstr" "prefix" "{{ $SOURCES }}/zashboard/locale_strings" \
                        "--argstr" "upstream" "${nixpkgs}" \
                        "--argstr" "tool" "${tool}" \
                        "--include" "nixpkgs=${nixpkgs}" \
                        "${./proc/check_strings.nix}"
                }
            }

            pane split_direction="horizontal" {

                pane command="nix-shell" name="phpunit on php 7.4 (for zabbix 6.0+)" {
                    args \
                        "--run" "fg" \
                        "--argstr" "uiroot" "{{ $UI_ROOT }}" \
                        "--argstr" "upstream" "${nixpkgs}" \
                        "--include" "nixpkgs=${nixpkgs}" \
                        "${./proc/phpunit_run_74.nix}"
                }

                pane command="nix-shell" name="phpunit on php 8.0 (for zabbix 7.0+)" {
                    args \
                        "--run" "fg" \
                        "--argstr" "uiroot" "{{ $UI_ROOT }}" \
                        "--argstr" "upstream" "${nixpkgs}" \
                        "--include" "nixpkgs=${nixpkgs}" \
                        "${./proc/phpunit_run_80.nix}"
                }

                pane command="nix-shell" name="phpunit on php 8.3 (for zabbix ~)" {
                    args \
                        "--run" "fg" \
                        "--argstr" "uiroot" "{{ $UI_ROOT }}" \
                        "--argstr" "upstream" "${nixpkgs}" \
                        "--include" "nixpkgs=${nixpkgs}" \
                        "${./proc/phpunit_run_83.nix}"
                }

                pane command="nix-shell" name="phpunit on php 8.4 (for zabbix ^)" {
                    args \
                        "--run" "fg" \
                        "--argstr" "uiroot" "{{ $UI_ROOT }}" \
                        "--argstr" "upstream" "${nixpkgs}" \
                        "--include" "nixpkgs=${nixpkgs}" \
                        "${./proc/phpunit_run_84.nix}"
                }

            }
        }
    }
  '';
}
# vim: ts=4 sw=4
