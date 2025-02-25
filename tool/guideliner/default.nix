{ pkgs }:
let
  checks = ./.;
in
with pkgs.lib;
pkgs.writeShellScriptBin "guideliner" ''
  grep_php() {
    ${pkgs.tree-grepper}/bin/tree-grepper --query php "$1"
  }

  for check in ${checks}/*.scm
  do
    query="$(cat $check)"
    guideline="''${check%scm}md"

    if [ -e "$guideline" ]
    then
      ${getExe pkgs.glow} "$guideline"
    else
      ${getExe pkgs.glow} "$guideline"
    fi

    result="$(grep_php "$query")"

    if [ ! -z "$result" ]
    then
      echo "$result"
      echo "## NOT OK!" | ${getExe pkgs.glow} -
    else
      echo "# OK!" | ${getExe pkgs.glow} -
    fi

    echo "---" | ${getExe pkgs.glow} -

  done
''
