{ prefix, upstream ? <nixpkgs> }:
let
  pkgs = import upstream { };
in
with pkgs.lib;
pkgs.mkShell {
  packages = with pkgs; [
    git
    perl
    automake
    autoconf
    busybox
    gcc
    gnumake
  ];
  shellHook = ''
    copyfromto() {
      src="$1"
      tmp="$2"
      [[ -d "$tmp" ]] && rm -rf "$tmp"
      mkdir -p "$tmp"
      cd "$tmp"
      cp -r "$src/src" "$tmp/src"
      cp -r "$src/database" "$tmp/database"
      cp -r "$src/include" "$tmp"
      cp -r "$src/man" "$tmp"
      cp -r "$src/misc" "$tmp"
      cp -r "$src/m4" "$tmp"
      cp -r "$src/create" "$tmp"
      cp -r "$src/conf" "$tmp"
      cp -r "$src/templates" "$tmp"

      cp "$src/configure.ac" "$tmp"
      cp "$src/AUTHORS" "$tmp"
      cp "$src/Makefile.am" "$tmp"
      cp "$src/ChangeLog" "$tmp"
      cp "$src/NEWS" "$tmp"
      cp "$src/README" "$tmp"
      cp "$src/bootstrap.sh" "$tmp"
    }

    build() {
      tmp=/tmp/builder-$ZABBIX_REVISION
      mkdir -p "$tmp"
      copyfromto $PWD "$tmp"

      aclocal -I m4
      autoconf
      autoheader
      automake -a
      automake

      ./configure --with-mysql --with-postgresql

      make dbschema

      cd -

      dst="${prefix}"
      mkdir -p "$dst"

      cat \
        "$tmp/database/postgresql/schema.sql" \
        "$tmp/database/postgresql/images.sql" \
        "$tmp/database/postgresql/data.sql" \
      > "$dst/postgresql.sql"

      cat \
          "$tmp/database/mysql/schema.sql" \
          "$tmp/database/mysql/images.sql" \
          "$tmp/database/mysql/data.sql" \
      > "$dst/mysql.sql"
    }

    fg() {
      ${getExe pkgs.tree} ${prefix}
      export ZABBIX_REVISION=$(${getExe pkgs.git} rev-parse HEAD)
      touch ${prefix}/builds.log
      tail ${prefix}/builds.log
      # tail ./create/src/schema.tmpl | grcat <(printf "%s\n%s" "regexp=(\d\d\d+)" "colors=red")
      echo "=== $PWD ==="
      if read -r -p "Build DB schema?"
      then
        build

        ${pkgs.lib.getExe pkgs.tree} ${prefix}
        echo $(date) : $(git rev-parse HEAD) >> ${prefix}/builds.log
      fi
    }
  '';
}
