export RUNTIME_PATH=$HOME/.cache/zsharp

[ ! -d "$RUNTIME_PATH" ] && mkdir -p "$RUNTIME_PATH"

rtp:db_scheme() {
  echo -n "$(rtp:_make builds/scheme/"$1")"
}

rtp:agent() {
  echo -n "$(rtp:_make builds/agent)"
}

rtp:dst:server() {
  [ -z "$1" ] && echo "<ERROR:rtp:dst:server>" && exit 7
  echo -n "$(rtp:_make builds/server/"$1")"
}

rtp:dst:agents() {
  [ -z "$1" ] && echo "<ERROR:rtp:dst:agents>" && exit 7
  echo -n "$(rtp:_make builds/agents/"$1")"
}

rtp:dst:proxy() {
  [ -z "$1" ] && echo "<ERROR:rtp:dst:proxy>" && exit 7
  echo -n "$(rtp:_make builds/proxy/"$1")"
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

# <src> <uniquesha>
sandbox:cd() {
  dir="$(rtp:_make sandbox/"$2")"
  rm -rf "$dir"
  cp -R "$1" "$dir"
  cd "$dir" || exit 8
}
