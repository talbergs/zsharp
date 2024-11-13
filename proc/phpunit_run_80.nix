{ uiroot, upstream ? <nixpkgs> }:
let
  pkgs = import upstream { };
in
pkgs.mkShell {
  shellHook = ''
    build() {
      cd ${uiroot}/tests/unit
      if [[ ! -e phpunit-8.5.40.phar ]]
      then
        ${pkgs.lib.getExe pkgs.wget} https://phar.phpunit.de/phpunit-8.5.40.phar
      fi

      nix run github:fossar/nix-phps#php80 -- \
        phpunit-8.5.40.phar \
          --bootstrap=./bootstrap.php \
          --configuration=./phpunit.xml \
          ./include/
    }

    fg() {
      if read -r -p "Build and run unit tests?"
      then
        build
      fi
    }
  '';
}
