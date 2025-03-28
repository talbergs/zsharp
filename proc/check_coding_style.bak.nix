{ tool, upstream, session }:
let
  pkgs = import upstream { };
in with pkgs.lib;
pkgs.mkShell {
  shellHook = ''
    source ${tool}/rtp.sh

    FILES=''${FILES:-$(state:get:guideliner-files ${session})}
    FILES=''${FILES:-"<preset:all>"}
    GIT_FILTER_THEN=
    GIT_FILTER_NOW=
    VERBOSE=
    SINGLE_CHECK=

    halt=
    trap halt=1 SIGINT

    fg() {
      clear

      printf "$(tput setaf 2)%s\n%s\n%s\n%s$(tput sgr0)\n\n" \
        "1) Find coding style issues?" \
        "2) Set a specific coding style check (current: $SINGLE_CHECK)?" \
        "3) Set files (current: $FILES)"
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
            echo "also not implemented (sleep 3)"
            sleep 3
          fi

          for file in $files
          do
            [ ! -z "$halt" ] && break
            SINGLE_CHECK=$SINGLE_CHECK nix run ${tool}#guideliner -- "$file" "$VERBOSE"
          done

          echo Process complete. Press any key.
        ;;
        2)
            SINGLE_CHECK=$(nix run ${tool}#guideliner -- "--" "check-picker")
            fg
        ;;
        3)
          printf "$(tput setaf 2)%s\n%s\n%s\n%s$(tput sgr0)\n\n" \
            "1) Set <then..now> commit to filter git patches?" \
            "2) Select files via FZF multi-select (TAB-key)?" \
            "3) Use <preset:all> (php files excluding ./vendor and ./tests)"
          read -N 1 -e -p "[1][2][3]>:" var

          case "$var" in
            1)
              GIT_FILTER_THEN=HEAD^^
              GIT_FILTER_NOW=HEAD

              patch_to_lines='
              while ($p = trim(fgets(STDIN), " +")) {
                 [$start, $len] = explode(",", $p . ",1");
                 if ($len == 0) continue;
                 $end = $start + $len - 1;
                 foreach (range($start, $end) as $lineno) {
                   echo "** " . $lineno . PHP_EOL;
                 }
              }
              '

              while read GIT_FILE
              do
                ${getExe pkgs.git} diff -U0 $GIT_FILTER_THEN..$GIT_FILTER_NOW -- $GIT_FILE \
                  | rg "^@@" \
                  | cut -d ' ' -f 3 \
                  | ${getExe pkgs.php} -r "$patch_to_lines"
              done < <(${getExe pkgs.git} diff \
                --no-renames \
                --name-only \
                --diff-filter=AM $GIT_FILTER_THEN..$GIT_FILTER_NOW \
              )
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
        *)
          echo "Choose an option."
          fg
        ;;
      esac
    }
  '';
}
