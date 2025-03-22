{ pkgs }:
let
  checks = ./.;
in
with pkgs.lib;
pkgs.writeShellScriptBin "guideliner" ''
  file="$1"
  verbose="$2"
  subcommand="$2"

  set +u
  SINGLE_CHECK="$SINGLE_CHECK"
  set -u

  if [ -z "$file" ]
  then
    echo "$0 <FILE> <VERBOSE?>"
    echo "> OR"
    echo "$0 -- <subcommand>"
    exit 7
  fi

  if [ "$file" == "--" ]
  then
      case "$subcommand" in
        check-picker)
          echo -n "" > /tmp/guideliner-guides
          for check in ${checks}/*.scm
          do
            fname="$(basename $check)"
            guideline="''${check%scm}md"
            guideline="$(cat $guideline)"
            echo "$fname | $guideline" >> /tmp/guideliner-guides
          done
          cat /tmp/guideliner-guides \
            | ${getExe pkgs.fzf} \
            | ${pkgs.uutils-coreutils-noprefix}/bin/cut -d '.' -f 1
          exit 0
        ;;
        *)
          $0
          exit 9
        ;;
      esac
  fi

  grep_php() {
    ${pkgs.tree-grepper}/bin/tree-grepper \
      --query php "$1" \
      --format pretty-json \
      "$file"
  }

  for check in ${checks}/*.scm
  do
    query="$(cat $check)"
    guideline="''${check%scm}md"
    processor="''${check%scm}php"

    if [ ! -z "$SINGLE_CHECK" ]
    then
      if [ "$SINGLE_CHECK" != "$(basename "''${check%.scm}")" ]
      then
        continue
      fi
    fi

    if [ ! -e "$processor" ]
    then
      processor="${checks}/processor.php"
    fi

    result=$(
      grep_php "$query" \
        | ${getExe pkgs.php} "$processor"
    )

    if [ ! -z "$result" ]
    then
      ${getExe pkgs.glow} "$guideline"
      echo "$result"
    elif [ ! -z "$verbose" ]
    then
      ${getExe pkgs.glow} "$guideline"
    fi
  done
''
