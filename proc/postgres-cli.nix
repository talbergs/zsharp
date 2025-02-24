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
      clear
      echo DB_NAME="${dbname}"
      echo DB_PORT="${dbport}"

      printf "$(tput setaf 2)%s\n%s$(tput sgr0)\n\n" \
        "1) Start psql client?"
      read -N 1 -e -p "[1]>:" var

      case "$var" in
        1)
          build
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
