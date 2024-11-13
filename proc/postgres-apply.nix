{
  dbport ? "5432",
  dbname,
  scheme,
  upstream ? <nixpkgs>
}:
let
  pkgs = import upstream { };
in
pkgs.mkShell {
  packages = with pkgs; [
    less
    postgresql
  ];
  shellHook = ''
    build() {
      echo 'drop database "${dbname}";' | psql --host=0.0.0.0 --port=${dbport} --dbname=postgres
      echo 'create database "${dbname}" encoding Unicode template template0;' | psql --host=0.0.0.0 --port=${dbport} --dbname=postgres
      echo '\i ${scheme};' | psql --host=0.0.0.0 --port=${dbport} --dbname=${dbname}
    }

    fg() {
      if read -r -p "RE-apply db dump?"
      then
        build
      fi
    }
  '';
}
