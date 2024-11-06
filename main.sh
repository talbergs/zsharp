#!/usr/bin/env bash
USAGE="Usage:  ${CMD:=${0##*/}} [(-v|--verbose)] [--name=TEXT] [(-o|--output) FILE] [ARGS...]"

# helper functions
exit2 () { printf >&2 "%s:  %s: '%s'\n%s\n" "$CMD" "$1" "$2" "$USAGE"; exit 2; }
check () { { [ "$1" != "$EOL" ] && [ "$1" != '--' ]; } || exit2 "missing argument" "$2"; }  # avoid infinite loop

# parse command-line options
set -- "$@" "${EOL:=$(printf '\1\3\3\7')}"  # end-of-list marker
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
         --session ) check "$1" "$opt"; SESSION="$1"; shift;;
    -h | --help    ) printf "%s\n" "$USAGE"; exit 0;;

    # process special cases
    --) while [ "$1" != "$EOL" ]; do set -- "$@" "$1"; shift; done;;    # parse remaining as positional
    --[!=]*=*) set -- "${opt%%=*}" "${opt#*=}" "$@";;                   # "--opt=arg"  ->  "--opt" "arg"
    -[A-Za-z0-9] | -*[!A-Za-z0-9]*) exit2 "invalid option" "$opt";;     # anything invalid like '-*'
    -?*) other="${opt#-?}"; set -- "${opt%"$other"}" "-${other}" "$@";; # "-abc"  ->  "-a" "-bc"
    *) set -- "$@" "$opt";;                                             # positional, rotate to the end
  esac
done; shift

# Fill in defaults.
SESSION=${SESSION:-zashboard}
DB_PORT=${DB_PORT:-5432}
UI_PORT=${UI_PORT:-8888}
DB_ROOT=${DB_ROOT:-$HOME/dbcluster}

# Required fields.
[ -z "$UI_ROOT" ] && exit2 "Option must be set" "--ui-root"
[ -z "$SOURCES" ] && exit2 "Option must be set" "--sources"
[ -z "$DB_NAME" ] && exit2 "Option must be set" "--db-name"

# TODO: validate config - paths exist on FS, being directories of type, numeric port numbers.

# Store config.
printf "UI_ROOT=%s\nUI_PORT=%s\nDB_PORT=%s\nDB_NAME=%s\nDB_ROOT=%s\nSOURCES=%s\nSESSION=%s" \
    "$UI_ROOT" "$UI_PORT" "$DB_PORT" "$DB_NAME" "$DB_ROOT" "$SOURCES" "$SESSION" \
    | jq -nR 'reduce ( inputs | split("=") ) as [ $k, $v ] ( {}; . + { ($k): $v } )' \
> ./config.sh
# TODO: store into runtime, not PWD

jq < ./config.sh
if read -r -p "run this?"
then
    php ./main.php ./config.sh &

    zellij d --force "$SESSION" # delete session, TODO: resurrect or smth
    zellij -s "$SESSION"
fi
