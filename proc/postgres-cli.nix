{
  dbport ? "5432",
  dbname ? "postgres",
}:
let
  pkgs = import <nixpkgs> { };
in
pkgs.mkShell {
  packages = with pkgs; [
    less
    postgresql
  ];
  shellHook = ''
    psql --host=0.0.0.0 --port=${dbport} --dbname=${dbname}
  '';
}
