# TODO: this
{ pkgs, ... }:
with pkgs.lib;
let
  query = ''
  (

    (function_call_expression
      function: (name) @name
      arguments: (arguments (argument) @string)
    )

    (#eq? @name "_")
  )
  '';
in
pkgs.writeShellScriptBin "revision_locale_strings"
''
  exit2 () {
    printf >&2 "Usage: $(basename $0) <sha>"
    exit 2
  }

  sandbox () {
    rev=$(${getExe pkgs.git} rev-parse "''${1:-HEAD}")
    [[ $? == 0 ]] || exit2
    ( # archive
      ${getExe pkgs.git} archive "$rev" > "$tmp.tar"
      [ -d "$tmp" ] && rm -rf "$tmp"
      mkdir -p "$tmp"
      ${getExe pkgs.gnutar} -xf "$tmp.tar" -C "$tmp"
    )
  }

  fg () {
    tmp=/tmp/src$rev


    cd "$tmp"
    ${pkgs.tree-grepper}/bin/tree-grepper --query php "${query}" --format json \
      | jq '.[].matches.[].text' --raw-output \
      | sort -u \
      > "''${tmp}str"

    rm -rf "$tmp" "$tmp.tar"
    printf "%sstr\t%s" "$tmp" "Ordered string references at $rev (''${1:-HEAD})"
  }
  fg $@
''

    # (#eq? @name "_")
    #   "_n" ; Supports unlimited parameters; placeholders must be defined as %1$s, %2$s etc.
    #   "_s" ; Translates the string and substitutes the placeholders with the given parameters.
    #   "_x" ; Translates the string with respect to the given context.
    #   "_xs" ; Translates the string with respect to the given context and replaces placeholders with supplied arguments.
    #   "_xn" ; Translates the string with respect to the given context and plural forms, also replaces placeholders with supplied arguments. If no translation is found, the original string will be used. Unlimited number of parameters supplied.
    # )
