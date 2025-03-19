{ tool, upstream, session }:
let
  pkgs = import upstream { };
in with pkgs.lib;
pkgs.mkShell {
  shellHook = ''
    source ${tool}/rtp.sh

    FILES=''${FILES:-$(state:get:guideliner-files ${session})}
    GIT_FILTER_THEN=
    GIT_FILTER_NOW=
    VERBOSE=

    halt=
    trap halt=1 SIGINT

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

          files="$FILES"
          if [ "$files" == "<preset:all>" ]
          then
            files_list=( $(${getExe pkgs.fd} --exclude '/vendor/' --exclude '/tests/' --extension php . ./ui) )
            files="''${files_list[*]}"
          elif [ "$files" ~= "<git:" ]
          then
            echo "not implemented (sleep 3)"
            sleep 3
          fi

          for file in $files
          do
            [ ! -z "$halt" ] && break
            nix run ${tool}#guideliner -- "$file" "$VERBOSE"
          done

          echo Process complete. Press any key.
        ;;
        2)
          printf "$(tput setaf 2)%s\n%s\n%s\n%s$(tput sgr0)\n\n" \
            "1) Set <then..now> commit to filter git patches?" \
            "2) Select files via FZF multi-select (TAB-key)?" \
            "3) Use <preset:all> (php files excluding ./vendor and ./tests)"
          read -N 1 -e -p "[1][2][3]>:" var

          case "$var" in
            1)
              GIT_FILTER_THEN=
              GIT_FILTER_NOW=
              export FILES="<git:HEAD^..HEAD>"
              echo "not implemented (sleep 3)"
              sleep 3
              export FILES=
            ;;
            2)
              files_list=( $(${getExe pkgs.fzf} --multi) )
              export FILES="''${files_list[*]}"
            ;;
            3)
              export FILES="<preset:all>"
            ;;
          esac

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
