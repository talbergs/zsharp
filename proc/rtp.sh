export RUNTIME_PATH=$HOME/.cache/zsharp

rtp:get() {
  mkdir -p "$RUNTIME_PATH"
}

test2() {
  echo "=TEST 2="
}

test3() {
  echo "=TEST 3="
}

echo "=TEST 4="
