echo "####"
echo "0 $0"
echo "1 $1"
echo "##"
echo www "$ZASHBOARD_UI_DIR"
echo "##__"

cd "$ZASHBOARD_UI_DIR" || exit 77

nix run "$1"
