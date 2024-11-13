{
  pgdata,
  dbport ? "5432",
  upstream ? <nixpkgs>
}:
let
  pkgs = import upstream { };
in
pkgs.mkShell {
  packages = with pkgs; [
    postgresql
    cowsay
  ];
  shellHook = ''
    export PGDATA=${pgdata}
    fg_postgres() {
      trap "pg_ctl -D $PGDATA stop && cowsay server stopped on $PGDATA:${dbport}" EXIT

      if ! test -d $PGDATA
      then
        pg_ctl initdb -D $PGDATA
        sed -i "s|^#port.*$|port = ${dbport}|" $PGDATA/postgresql.conf
      fi

      # These are only suitable for development.
      HOST_COMMON="host\s\+all\s\+all"
      sed -i "s|^$HOST_COMMON.*127.*$|host all all 0.0.0.0/0 trust|" $PGDATA/pg_hba.conf
      sed -i "s|^$HOST_COMMON.*::1.*$|host all all ::/0 trust|"      $PGDATA/pg_hba.conf

      pg_ctl                                                  \
        -D $PGDATA                                            \
        -l $PGDATA/postgres.log                               \
        -o "-c unix_socket_directories='$PGDATA'"             \
        -o "-c listen_addresses='*'"                          \
        -o "-c log_destination='stderr'"                      \
        -o "-c logging_collector=on"                          \
        -o "-c log_directory='log'"                           \
        -o "-c log_filename='postgresql-%Y-%m-%d_%H%M%S.log'" \
        -o "-c log_min_messages=info"                         \
        -o "-c log_min_error_statement=info"                  \
        -o "-c log_connections=on"                            \
        start

      tail -F $PGDATA/postgres.log
    }

    fg() {
      if read -r -p "Start postgres cluster in ${pgdata}?"
      then
        fg_postgres
      fi
    }
  '';
}
