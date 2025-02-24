{
  dbport ? "5432",
  dbname,
  session,
  tool,
  upstream
}:
let
  pkgs = import upstream { };
in
with pkgs.lib;
pkgs.mkShell {
  packages = with pkgs; [
    less
    postgresql
  ];
  shellHook = ''
    source ${tool}/rtp.sh

    fg() {
      clear
      echo "List: $(rtp:db_scheme '${session}')"
      ${getExe pkgs.tree} "$(rtp:db_scheme '${session}')"

      printf "$(tput setaf 2)%s\n%s$(tput sgr0)\n\n" \
        "1) RE-apply db dump?"
      read -N 1 -e -p "[1]>:" var

      case "$var" in
        1)
          scheme="$(rtp:db_scheme '${session}')/postgresql.sql"
          echo 'drop database "${dbname}";' | psql --host=0.0.0.0 --port=${dbport} --dbname=postgres
          echo 'create database "${dbname}" encoding Unicode template template0;' | psql --host=0.0.0.0 --port=${dbport} --dbname=postgres
          echo "\i $scheme;" | psql --host=0.0.0.0 --port=${dbport} --dbname=${dbname}
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
