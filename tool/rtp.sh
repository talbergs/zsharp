export RUNTIME_PATH=$HOME/.cache/zsharp

[ ! -d "$RUNTIME_PATH" ] && mkdir -p "$RUNTIME_PATH"

rtp:db_scheme() {
  echo -n "$(rtp:_make builds/db_scheme)"
}

rtp:agent() {
  echo -n "$(rtp:_make builds/agent)"
}

rtp:src:sha() {
  [ -z "$1" ] \
    && echo -n "$(rtp:_make src)" \
    || echo -n "$(rtp:_make "src/$1")"
}

rtp:_make() {
  made="$RUNTIME_PATH/$1"
  [ ! -d "$made" ] && mkdir -p "$made"
  echo -n "$made"
}
