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

      # TODO: Set files => sumbenu with options, fileset presets or picker.
      # TODO: add trap for user signals to work accross the whole for loop
      printf "$(tput setaf 2)%s\n%s\n%s\n%s\n%s$(tput sgr0)\n\n" \
        "1) Find coding style issues?" \
        "2) Set files (current: $FILES)" \
        "3) Set files to <preset:all>?" \
        "4) Set git revision then&now filter (current: )?" \
        "5) Enable verbose mode? (current: $VERBOSE)"
      read -N 1 -e -p "[1][2][3][4][5]>:" var

      case "$var" in
        1)
          if [ -z "$FILES" ]
          then
            echo ERROR: select at least one file
            exit 7
          fi

          files="$FILES"
          if [ "$files" == "<preset:all>" ]
          then
            files_list=( $(${getExe pkgs.fd} --exclude '/vendor/' --exclude '/tests/' --extension php . ./ui) )
            files="''${files_list[*]}"
          fi

          for file in $files
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
          export FILES="<preset:all>"
          state:set:guideliner-files ${session} "$FILES"
          fg
        ;;
        4)
          echo "NOT YET IMPLEMENTED (sleep 3)"
          sleep 3
          fg
        ;;
        5)
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
