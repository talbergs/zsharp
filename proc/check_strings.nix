# on run 3)
#  git archive tmp dirs
{ tool, upstream ? <nixpkgs> }:
let
  pkgs = import upstream { };
in with pkgs.lib;
pkgs.mkShell {
  shellHook = ''
    source ${tool}/rtp.sh

    extract() {
      rev=$(${getExe pkgs.git} rev-parse "''${1:-000000}")

      if [[ $? != 0 ]]; then
        printf >&2 "$1 not found in $PWD"
        exit 2
      fi

      tmp="$(rtp:src:sha $rev)"
      ${getExe pkgs.git} archive "$rev" > "$tmp.tar"
      ${getExe pkgs.gnutar} -xf "$tmp.tar" -C "$tmp"

      echo -n "$tmp"
    }

    jira_fmt() {
      tput bold
      printf "Strings added:\n%s\n" "$(${pkgs.diffutils}/bin/diff "$1" "$2")"
      printf "Strings deleted:\n%s\n" "$(${pkgs.diffutils}/bin/diff "$2" "$1")"
      tput sgr0
    }

    picker() {
      ${getExe pkgs.git} log --abbrev-commit --oneline \
        | ${getExe pkgs.fzf} \
        | cut --fields 1 -d ' '
    }

    fg() {
      then=''${then:-HEAD^}
      now=''${now:-HEAD}
      clear

      printf "$(tput setaf 2)%s\n%s\n%s$(tput sgr0)\n\n" \
        "1) Set 'then' <SHA>? (current: $then)" \
        "2) Set 'now' <SHA>? (current: $now)" \
        "3) Find translation changes?"
      read -N 1 -e -p "[1][2][3]>:" var

      case "$var" in
        1)
          then=$(picker)
          fg
        ;;
        2)
          now=$(picker)
          fg
        ;;
        3)
          printf ".. extracting %s and %s revisions\n" "$then" "$now"

          dir_then=$(extract "$then")
          rev_then=$(basename "$dir_then" | head -c 7)

          dir_now=$(extract "$now")
          rev_now=$(basename "$dir_now" | head -c 7)

          printf ".. extracted as %s and %s\n" "$rev_then" "$rev_now"

          (
            nix run ${tool}#get_translation_strings -- "$dir_then" > "$(rtp:src:sha)/$rev_then.php"
            nix run ${tool}#get_translation_strings -- "$dir_now" > "$(rtp:src:sha)/$rev_now.php"
          ) 2> /dev/null

          echo '<?php' > /tmp/diff.php
          echo '$then = unserialize(file_get_contents(getenv("THEN")));' >> /tmp/diff.php
          echo '$now = unserialize(file_get_contents(getenv("NOW")));' >> /tmp/diff.php
          echo '$res = "";' >> /tmp/diff.php
          echo '$res .= sprintf("Strings added:\n");' >> /tmp/diff.php
          echo 'foreach(array_diff($now, $then) as $s) {$res .= sprintf("- _%s_\n", $s);};' >> /tmp/diff.php
          echo '$res .= sprintf("Strings removed:\n");' >> /tmp/diff.php
          echo 'foreach(array_diff($then, $now) as $s) {$res .= sprintf("- _%s_\n", $s);};' >> /tmp/diff.php
          echo 'echo $res;' >> /tmp/diff.php

          tput bold
          THEN="$(rtp:src:sha $rev_then).php" \
          NOW="$(rtp:src:sha $rev_now).php" \
          ${pkgs.php}/bin/php -f /tmp/diff.php
          tput sgr0

          printf "\n\nrefs: $(rtp:src:sha $rev_then) $(rtp:src:sha $rev_now)"
        ;;
        *)
          echo "Choose an option."
          fg
        ;;
      esac
    }
  '';
}
