{ pkgs, ... }:
{
  db_scheme = import ./db_scheme.nix { inherit pkgs; };
  zabbix_server = import ./zabbix_server.nix { inherit pkgs; };
  zabbix_agents = import ./zabbix_agents.nix { inherit pkgs; };
  zabbix_proxy = import ./zabbix_proxy.nix { inherit pkgs; };
  zabbix_webservice = import ./zabbix_webservice.nix { inherit pkgs; };
}
