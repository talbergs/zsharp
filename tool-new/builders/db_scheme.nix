{ pkgs, ... }: pkgs.writeShellApplication {
  name = "db_scheme";
  runtimeInputs = with pkgs; [
    git
    perl
    automake
    autoconf
    gcc
    gnumake
  ];
  text = ''
    dst="$DST"
    src="$SRC"
    tmp=$(mktemp -d)
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

    aclocal -I m4
    autoconf
    autoheader
    automake -a
    automake

    ./configure --with-mysql --with-postgresql

    make dbschema

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
  '';
}
