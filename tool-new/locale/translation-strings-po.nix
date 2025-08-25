{ pkgs, ... }:
pkgs.writeShellScriptBin "get_translation_strings"
''
  if [[ -z "$1" ]];then
    printf >&2 "Usage: $(basename $0) <dir>"
    exit 2
  fi

  ${pkgs.gettext}/bin/xgettext \
    --files-from=<(find $1 -type f -name "*.php") \
    --output=/tmp/portable_object \
    --keyword=_n:1,2 \
    --keyword=_s \
    --keyword=_x:1,2c \
    --keyword=_xs:1,2c \
    --keyword=_xn:1,2,4c \
    --from-code=UTF-8 \
    --language=php \
    --no-wrap \
    --sort-output \
    --no-location \
    --omit-header

  ${pkgs.php}/bin/php -f ${./po_to_list.php} -- /tmp/portable_object
''
