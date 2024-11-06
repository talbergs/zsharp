# Generates kdl config.
{ pkgs, system-db, ... }:
with pkgs;
with pkgs.lib;
''
  layout {
    pane_template name="follow-log" command="tail"
    default_tab_template {
        pane size=1 borderless=true {
            plugin location="zellij:tab-bar"
        }
        children
        pane size=2 borderless=true {
            plugin location="zellij:status-bar"
        }
        pane size=1 borderless=true {
            plugin location="file:/home/nixos/MT/repos/talbergs/zashboard/zjstatus.wasm" {
                format_left   "{mode} #[fg=#89B4FA,bold]{session}"
                format_center "{tabs}"
                format_right  "{command_git_branch} {datetime}"
                format_space  ""

                border_enabled  "false"
                border_char     "─"
                border_format   "#[fg=#6C7086]{char}"
                border_position "top"

                hide_frame_for_single_pane "true"

                mode_normal  "#[bg=blue] "
                mode_tmux    "#[bg=#ffc387] "

                tab_normal   "#[fg=#6C7086] {name} "
                tab_active   "#[fg=#9399B2,bold,italic] {name} "

                command_git_branch_command     "git rev-parse --abbrev-ref HEAD"
                command_git_branch_format      "#[fg=blue] {stdout} "
                command_git_branch_interval    "10"
                command_git_branch_rendermode  "static"

                datetime        "#[fg=#6C7086,bold] {format} "
                datetime_format "%A, %d %b %Y %H:%M"
                datetime_timezone "Europe/Berlin"
            }
        }
    }

    tab name="Tab: Log" {
      pane {
        name "PHP.log.error"
        command "tail" 
        args "-F" "/tmp/php.error.log"
      }
      pane {
        name "PHP.symfony.dump"
        command "nix" 
        args "run" "github:talbergs/belt#run_php_dump"
      }
      pane {
        name "ZABBIX.log"
        command "tail" 
        args "-F" "/tmp/zabbix_server.log"
      }
      pane {
        name "AGENT2.log"
        command "tail" 
        args "-F" "/tmp/zabbix_agent2.log"
      }
    }

    tab name="Tab: Proc" split_direction="vertical" {

      pane {
        name "PostgreSQL"
        command "${getExe bash}" 
        args "${./proc/postgres.sh}" "${./proc/postgres.nix}"
      }

      pane {
        name "PostgreSQL-client"
        command "${getExe bash}" 
        args "${./proc/postgres-cli.sh}" "${./proc/postgres-cli.nix}"
      }

      pane {
        name "PHP.server"
        command "${getExe bash}" 
        args "${./proc/php.sh}" "github:talbergs/belt#run_php"
      }

      pane {
        name "ZABBIX.server"
        command "${getExe bash}" 
        args "-c" "${pkgs.zabbix.server}/bin/zabbix_server -f"
      }

      pane {
        name "ZABBIX.agent2"
        command "${getExe bash}" 
        args "-c" "${pkgs.zabbix.agent2}/bin/zabbix_agent2 -f"
      }

    }

    tab name="Tab: dev" {
      pane {
        name ""
        command "tail" 
        args "-F" "/tmp/php.error.log"
      }
    }

  }
''
