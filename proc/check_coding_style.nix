{ tool, upstream, session }:
let
  pkgs = import upstream { };
in with pkgs.lib;
pkgs.mkShell {
  shellHook = ''
    source ${tool}/rtp.sh

    FILES=''${FILES:-$(state:get:guideliner-files ${session})}
    VERBOSE=

    fg() {
      clear

      printf "$(tput setaf 2)%s\n%s\n%s$(tput sgr0)\n\n" \
        "1) Find coding style issues?" \
        "2) Set files (current: $FILES)" \
        "3) Enable verbose mode? (current: $VERBOSE)"
      read -N 1 -e -p "[1][2][3]>:" var

      case "$var" in
        1)
          if [ -z "$FILES" ]
          then
            echo ERROR: select at least one file
            exit 7
          fi

          for file in $FILES
          do
            nix run ${tool}#guideliner -- "$file" "$VERBOSE"
          done

          echo Process complete. Press any key.
        ;;
        2)
          files_list=( $(${getExe pkgs.fzf} --multi) )
          export FILES="''${files_list[*]}"

          state:set:guideliner-files ${session} "$FILES"
          fg
        ;;
        3)
          [ -z "$VERBOSE" ] && export VERBOSE=yes || export VERBOSE=
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
