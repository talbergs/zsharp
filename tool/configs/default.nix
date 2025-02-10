{ pkgs, ... }:
let mk_tmpl = layout_template: pkgs.writeShellApplication {
    name = "layout_generator";
    runtimeInputs = with pkgs; [
      gnused
    ];
    text = ''
      set +o nounset

      for i in "$@"; do
          declare "$i";
      done

      # Prefix all double quotes and "$" with backslash, then unwrap mustaches.
      prep-tmpl() {
          sed -e 's/"/\\"/g' -e 's/\$/\\$/g' -e 's/{{\s*\\\(\$\w*\)\s*}}/\1/g' "$1"
      }

      eval "echo \"$(prep-tmpl "${layout_template}")\""
    '';
  };
in
{
  server_conf = mk_tmpl ./server.conf;
  agent_conf = mk_tmpl ./agent.conf;
  zabbix_conf_php = mk_tmpl ./zabbix.conf.php;
  selenium_bootstrap_php = mk_tmpl ./phpunit.bootstrap.selenium.php;
  selenium_zabbix_conf_php = mk_tmpl ./selenium.zabbix.conf.php;
}

