{ tool, upstream, session }:
let
  pkgs = import upstream { };
in with pkgs.lib;
pkgs.mkShell {
  shellHook = ''
    source ${tool}/rtp.sh

    then=''${then:-HEAD^}
    now=''${now:-HEAD}
    checkid=
    files=

    halt=
    trap halt=1 SIGINT
    run() {
      for check_file in $files
      do
        [ ! -z "$halt" ] && break
        if [ ! -z "$checkid" ]
        then
          issues=( $(nix run ${tool}#guideliner -- one "$check_file" "$checkid") )
        else
          issues=( $(nix run ${tool}#guideliner -- all "$check_file") )
        fi
        issues=''${issues[*]}
        for issue in $issues
        do
          [ ! -z "$halt" ] && break
          eval $(echo -n "$issue" | jq -r 'to_entries | .[] | .key + "=" + (.value | @sh)')
          if [ ! -z "$patches_filter" ]
          then
            if ! echo -n "$patches_filter" | rg "$file:$line" > /dev/null
            then
              continue
            fi
          fi

          printf '* %s\n * `%s:%s`\n\n%s\n\n---' "$(basename $docs)" "$file" "$line" "$(cat $docs)" | ${getExe pkgs.glow}
        done
      done

      read -e -p "Process complete. Press any key." && fg
    }

    fg() {
      patches_filter=
      clear

      printf "$(tput setaf 2)%s\n%s\n%s\n%s\n%s\n%s$(tput sgr0)\n\n" \
        "1) Set 'then' <SHA>? (current: $then)" \
        "2) Set 'now' <SHA>? (current: $now)" \
        "3) Find coding style issues between the revisions?" \
        "4) Find coding style issues in file(s)?" \
        "5) Select a specific coding style check (current: $checkid)?"
      read -N 1 -e -p "[1][2][3][4][5]>:" var

      case "$var" in
        1) read -e -p "then>:" then && fg ;;
        2) read -e -p "now>:" now && fg ;;
        3)
          patches_filter="$(nix run ${tool}#git-patches -- "$then" "$now")"
          files=( $(echo -n "$patches_filter" | cut -d: -f1 | sort -u) )
          files="''${files[*]}"
          run
        ;;
        4)
          printf "$(tput setaf 2)%s\n%s\n%s\n%s\n%s$(tput sgr0)\n\n" \
            "> Find coding style issues in file(s)" \
            "1) Run preset '--exclude /vendor/ --exclude /tests/ --extension php'?" \
            "2) Select folder(s)?" \
            "3) Select file(s)?" \
            "4) Run accross project?"
          read -N 1 -e -p "[1][2][3][4]>:" var

          case "$var" in
            1)
              files_list=( $(${getExe pkgs.fd} --exclude '/vendor/' --exclude '/tests/' --extension php . ./ui) )
              files="''${files_list[*]}"
              run
            ;;
            2)
              folders=( $(${getExe pkgs.fzf} --walker=dir --multi) )
              folders="''${folders[*]}"
              if [ ! -z "$folders" ]
              then
                files_list=( $(${getExe pkgs.fd} . $folders) )
                files="''${files_list[*]}"
                run
              else
                fg
              fi
            ;;
            3)
              files_list=( $(${getExe pkgs.fzf} --multi) )
              files="''${files_list[*]}"
              if [ ! -z "$files" ]
              then
                run
              else
                fg
              fi
            ;;
            4)
              files_list=( $(${getExe pkgs.fd} .) )
              files="''${files_list[*]}"
              if [ ! -z "$files" ]
              then
                run
              else
                fg
              fi
            ;;
            *) fg ;;
          esac
        ;;
        5) checkid=$(nix run ${tool}#guideliner -- "ls-picker") && fg ;;
        *) echo "Choose an option." && fg ;;
      esac
    }
  '';
}
