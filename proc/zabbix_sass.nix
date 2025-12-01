{ tool, upstream ? <nixpkgs> }:
let
  pkgs = import upstream { };
  builder = pkgs.writeShellScriptBin "builder" ''
    echo BUILDING STYLES in $PWD
    cmd="nix run ${tool}#sass --"
    # $cmd --no-cache --sourcemap=none sass/stylesheets/sass/screen.scss ui/assets/styles/blue-theme.css
    # $cmd --no-cache --sourcemap=none sass/stylesheets/sass/dark-theme.scss ui/assets/styles/dark-theme.css
    # $cmd --no-cache --sourcemap=none sass/stylesheets/sass/hc-light.scss ui/assets/styles/hc-light.css
    # $cmd --no-cache --sourcemap=none sass/stylesheets/sass/hc-dark.scss ui/assets/styles/hc-dark.css

    # cp sass/img/browser-sprite.png ui/assets/img/
    # cp sass/apple-touch-icon-120x120-precomposed.png ui/assets/img/
    # cp sass/apple-touch-icon-152x152-precomposed.png ui/assets/img/
    # cp sass/apple-touch-icon-180x180-precomposed.png ui/assets/img/
    # cp sass/apple-touch-icon-76x76-precomposed.png ui/assets/img/
    # cp sass/ms-tile-144x144.png ui/assets/img/
    # cp sass/touch-icon-192x192.png ui/assets/img/
    # cp sass/favicon.ico ui/

    $cmd --no-cache --sourcemap=none sass/stylesheets/sass/hc-dark.scss ui/assets/styles/hc-dark.css
    $cmd --no-cache --sourcemap=none sass/stylesheets/sass/hc-light.scss ui/assets/styles/hc-light.css
    [ -e sass/stylesheets/sass/dark-classic-theme.scss ] && \
    $cmd --no-cache --sourcemap=none sass/stylesheets/sass/dark-classic-theme.scss ui/assets/styles/dark-classic-theme.css
    $cmd --no-cache --sourcemap=none sass/stylesheets/sass/dark-theme.scss ui/assets/styles/dark-theme.css
    [ -e sass/stylesheets/sass/blue-classic-theme.scss ] && \
    $cmd --no-cache --sourcemap=none sass/stylesheets/sass/blue-classic-theme.scss ui/assets/styles/blue-classic-theme.css
    $cmd --no-cache --sourcemap=none sass/stylesheets/sass/blue-theme.scss ui/assets/styles/blue-theme.css

    cp sass/img/browser-sprite.png ui/assets/img/
    cp sass/apple-touch-icon-120x120-precomposed.png ui/assets/img/
    cp sass/apple-touch-icon-152x152-precomposed.png ui/assets/img/
    cp sass/apple-touch-icon-180x180-precomposed.png ui/assets/img/
    cp sass/apple-touch-icon-76x76-precomposed.png ui/assets/img/
    cp sass/ms-tile-144x144.png ui/assets/img/
    cp sass/touch-icon-192x192.png ui/assets/img/
    cp sass/favicon.ico ui/



  '';
in
with pkgs.lib;
pkgs.mkShell {
  shellHook = ''
    fg() {
      clear
      printf "$(tput setaf 2)%s\n%s$(tput sgr0)\n\n" \
        "1) Watch style files for sass builder?" \
        "2) Run sass builder?"
      read -N 1 -e -p "[1][2]>:" var
      case "$var" in
        1)
          ${getExe pkgs.fd} --extension scss \
          | ${getExe pkgs.entr} -p ${getExe builder}
        ;;
        2)
          ${getExe builder}
          fg
        ;;
        3)
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
