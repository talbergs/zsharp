echo "####"
echo "0 $0"
echo "1 $1"
echo "##"
echo dbport "$ZASHBOARD_PGPORT"
echo "##__"

nix-shell \
  --argstr dbport "$ZASHBOARD_PGPORT" \
  "$1"
