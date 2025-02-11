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
    echo "List: $(rtp:db_scheme '${session}')"
    ${getExe pkgs.tree} "$(rtp:db_scheme '${session}')"

    scheme="$(rtp:db_scheme '${session}')/postgresql.sql"

    build() {
      echo 'drop database "${dbname}";' | psql --host=0.0.0.0 --port=${dbport} --dbname=postgres
      echo 'create database "${dbname}" encoding Unicode template template0;' | psql --host=0.0.0.0 --port=${dbport} --dbname=postgres
      echo "\i $scheme;" | psql --host=0.0.0.0 --port=${dbport} --dbname=${dbname}
    }

    fg() {
      if read -r -p "RE-apply db dump?"
      then
        build
      fi
    }
  '';
}
