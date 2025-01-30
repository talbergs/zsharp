{ tool, uiroot, phpver, upstream ? <nixpkgs> }:
let
  pkgs = import upstream { };
in
pkgs.mkShell {
  shellHook = ''
    build() {
      cd ${uiroot}/tests/unit
      nix run ${tool}#phpunit${phpver} -- \
        --bootstrap=./bootstrap.php \
        --configuration=./phpunit.xml \
        ./include/
    }

    fg() {
      clear
      if read -r -p "Build and run unit tests?"
      then
        build
      fi
    }
  '';
}
