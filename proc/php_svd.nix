{ tool, upstream ? <nixpkgs> }:
let pkgs = import upstream { };
in pkgs.mkShell {
  shellHook = ''
    fg() {
      clear
      printf "$(tput setaf 2)%s\n%s$(tput sgr0)\n\n" \
        "1) Listen php var dumper cli on port 9912?"
      read -N 1 -e -p "[1]>:" var
      case "$var" in
        1)
          nix run ${tool}#phpsvd -- --host=0.0.0.0:9912 --format=cli
        ;;
        *)
          echo "Choose an option."
          fg
        ;;
      esac
    }
  '';
}
