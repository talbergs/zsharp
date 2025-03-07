{ pkgs }:
let
  checks = ./.;
in
with pkgs.lib;
pkgs.writeShellScriptBin "guideliner" ''
  file="$1"
  verbose="$2"

  if [ -z "$file" ]
  then
    echo "$0 <FILE> <VERBOSE?>"
    exit 7
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
