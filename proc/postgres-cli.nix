{
  dbport ? "5432",
  dbname ? "postgres",
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
      psql --host=0.0.0.0 --port=${dbport} --dbname=${dbname}
    }

    fg() {
      if read -r -p "Start psql client?"
      then
        build
      fi
    }
  '';
}
