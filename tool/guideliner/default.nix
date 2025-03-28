{ pkgs }:
let
  checks = ./.;
in
with pkgs.lib;
pkgs.writeShellScriptBin "guideliner" ''
  subcommand="$1"
  file="$2"
  checkid="$3"

  __main__() {
    case $subcommand in
      all) has_file && ls_checkids | ${pkgs.findutils}/bin/xargs -I '{}' $0 one $file '{}' ;;
      one) has_file && has_checkid && run_check ;;
      ls) ls_checkids ;;
      ls-picker) ls_picker ;;
      *) usage ;;
    esac
  }

  usage() {
    echo "Usage:"
    echo "  ~ $(basename $0) all <FILE>"
    echo "  ~ $(basename $0) one <FILE> <CHECKID>"
    echo "  ~ $(basename $0) ls"
    echo "  ~ $(basename $0) ls-picker"
    exit 7
  }

  has_file() {
    [ -z "$file" ] && echo "File must be specified!" && usage
    [ ! -e "$file" ] && echo "File '$file' must exist!" && usage
    return 0
  }

  has_checkid() {
    [ -z "$checkid" ] && echo "CheckID must be specified!" && usage
    [ ! -e "$(file_scm)" ] && echo "Unknown checkid($checkid)" \
      && echo -e "These are available:\n$(ls_checkids)" && exit 7
    return 0
  }

  ls_checkids() {
    for check in ${checks}/*.scm
    do echo $(basename ''${check%.scm})
    done
  }

  ls_picker() {
    for checkid in $(ls_checkids)
    do printf '%s| %s\n' $checkid "$(cat $(file_md))"
    done \
      | ${getExe pkgs.fzf} \
      | ${pkgs.uutils-coreutils-noprefix}/bin/cut -d '|' -f 1
  }

  file_scm() {
    echo -n ${checks}/$checkid.scm
  }

  file_md() {
    echo -n ${checks}/$checkid.md
  }

  file_php() {
    processor=${checks}/$checkid.php
    [ -e "$processor" ] && echo -n $processor || echo ${checks}/processor.php
  }

  run_check() {
    grep_php "$(cat $(file_scm))" \
      | DOCS="$(file_md)" \
      ${getExe pkgs.php} "$(file_php)"
  }

  grep_php() {
    ${pkgs.tree-grepper}/bin/tree-grepper \
      --query php "$1" \
      --format pretty-json \
      "$file"
  }

  __main__
''
