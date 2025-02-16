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
  dir="$(rtp:_make "sandbox/$2")"
  rm -rf "$dir"
  cp -R "$1" "$dir"
  cd "$dir" || exit 8
}

tmp:new() {
  dir="$(rtp:_make "tmp/$1")"
  rm -rf "$dir"
  echo -n "$(rtp:_make "tmp/$1")"
}

# <env> <name>
state:name() {
  state="$(rtp:_make "state/$1")/$2"
  [ ! -f "$state" ] && touch "$state"
  echo -n "$state"
}

# <env> <name>
state:get() {
  addr="$(state:name "$1" "$2")"
  cat "$addr"
}

# <env> <name> <value>
state:set() {
  echo -n "$3" > "$(state:name "$1" "$2")"
}

# <env> <value>
state:set:selenium-filter() {
  state:set "$1" "selenium-filter" "$2"
}

# <env>
state:get:selenium-filter() {
  state:get "$1" "selenium-filter"
}
