{ pkgs, layout_generator, ... }:
with pkgs.lib;
pkgs.writeShellApplication {
  name = "zsharp";
  runtimeInputs = with pkgs; [
    zellij
    layout_generator
  ];
  text = ''
    USAGE="Usage:  ''${CMD:=''${0##*/}} [(-s|--session)=NAME] [--sources=DIR] [--ui-root=DIR] [--db-name=NAME] [--db-port=PORT] [--ui-port=PORT] [--php-v(74|80|83|84)]"

    exit2 () { printf >&2 "%s:  %s: '%s'\n%s\n" "$CMD" "$1" "$2" "$USAGE"; exit 2; }
    check () { { [ "$1" != "$EOL" ] && [ "$1" != '--' ]; } || exit2 "missing argument" "$2"; }  # avoid infinite loop

    # parse command-line options
    set -- "$@" "''${EOL:=$(printf '\1\3\3\7')}"  # end-of-list marker
    while [ "$1" != "$EOL" ]; do
      opt="$1"; shift
      case "$opt" in
        #EDIT HERE: defined options
             --ui-root ) check "$1" "$opt"; UI_ROOT="$1"; shift;;
             --ui-port ) check "$1" "$opt"; UI_PORT="$1"; shift;;
             --db-port ) check "$1" "$opt"; DB_PORT="$1"; shift;;
             --db-root ) check "$1" "$opt"; DB_ROOT="$1"; shift;;
             --db-name ) check "$1" "$opt"; DB_NAME="$1"; shift;;
             --sources ) check "$1" "$opt"; SOURCES="$1"; shift;;
        -s | --session ) check "$1" "$opt"; SESSION="$1"; shift;;
             --php-v84 ) PHP_V84="yes";;
             --php-v83 ) PHP_V83="yes";;
             --php-v80 ) PHP_V80="yes";;
             --php-v74 ) PHP_V74="yes";;
        -h | --help    ) printf "%s\n" "$USAGE"; exit 0;;

        # process special cases
        # parse remaining as positional
        --) while [ "$1" != "$EOL" ]; do set -- "$@" "$1"; shift; done;;
        # "--opt=arg"  ->  "--opt" "arg"
        --[!=]*=*) set -- "''${opt%%=*}" "''${opt#*=}" "$@";;
        # anything invalid like '-*'
        -[A-Za-z0-9] | -*[!A-Za-z0-9]*) exit2 "invalid option" "$opt";;
        # "-abc"  ->  "-a" "-bc"
        -?*) other="''${opt#-?}"; set -- "''${opt%"$other"}" "-''${other}" "$@";;
        # positional, rotate to the end
        *) set -- "$@" "$opt";;
      esac
    done; shift

    # Defaults.
    SOURCES=''${SOURCES:-$PWD}
    UI_ROOT=''${UI_ROOT:-$SOURCES/ui}
    UI_PORT=''${UI_PORT:-8888}
    SESSION=''${SESSION:-$(basename "$SOURCES")}
    DB_NAME=''${DB_NAME:-$SESSION}
    DB_PORT=''${DB_PORT:-5432}
    DB_ROOT=''${DB_ROOT:-$HOME/dbcluster}
    DB_USER=$(whoami)
    PHP_V84=''${PHP_V84:-}
    PHP_V83=''${PHP_V83:-}
    PHP_V80=''${PHP_V80:-}
    PHP_V74=''${PHP_V74:-}
    PHP_VER=''${PHP_V74//yes/v74}''${PHP_V80//yes/v80}''${PHP_V83//yes/v83}''${PHP_V84//yes/v84}
    PHP_VER=''${PHP_VER:-''${PHP_V83//yes/v83}}

    # Validation.
    validate:numeric() { [[ "$1" =~ ^[0-9]+([.][0-9]+)?$ ]]; }
    validate:sources() { [[ -e "$1/bootstrap.sh" ]]; }
    validate:ui-root() { [[ -e "$1/zabbix.php" ]]; }
    validate:php-ver() { [[ -z "$1" ]] ||  [[ "$1" =~ ^yes$ ]]; }
    validate:numeric "$DB_PORT" || exit2 "Invalid option --db-port $DB_PORT" "Must be a number"
    validate:numeric "$UI_PORT" || exit2 "Invalid option --ui-port $UI_PORT" "Must be a number"
    validate:sources "$SOURCES" || exit2 "Invalid option --sources $SOURCES" "Must be Zabbix source"
    validate:ui-root "$UI_ROOT" || exit2 "Invalid option --ui-root $UI_ROOT" "Must be Zabbix UI source"
    validate:php-ver "$PHP_V74""$PHP_V80""$PHP_V83""$PHP_V84" || exit2 "Invalid option --php-$PHP_VER" "No more than one of these may be specified".

    cd "$(cd "$(dirname "$0")" && pwd)" || exit2 "Unknown error"

    if ${getExe pkgs.ripgrep} "^$SESSION\$" <(${getExe pkgs.zellij} list-sessions --short) > /dev/null
    then
      echo "* Session '$SESSION' exists."
      echo "o this will discard any options that were set"
      read -r -p "* Attach to it instead (y/n)? " yn <<< "n" # always no
      if [[ "$yn" == "y" ]]
      then
        ${getExe pkgs.zellij} attach "$SESSION"
        exit 0
      else
        ${getExe pkgs.zellij} delete-session -f "$SESSION"
      fi
    fi

    ${getExe pkgs.zellij} \
        --session "$SESSION" \
        --new-session-with-layout <(${getExe layout_generator} \
                SESSION="$SESSION" \
                SOURCES="$SOURCES" \
                DB_PORT="$DB_PORT" \
                UI_ROOT="$UI_ROOT" \
                UI_PORT="$UI_PORT" \
                DB_ROOT="$DB_ROOT" \
                DB_NAME="$DB_NAME" \
                DB_USER="$DB_USER" \
                PHP_VER="$PHP_VER" \
                PWD="$PWD") \
        options \
            --simplified-ui true
  '';
}
