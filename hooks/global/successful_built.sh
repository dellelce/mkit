
#
pkg="$1"; [ -z "$pkg" ] && exit 1
touch "$WORKDIR/state/${pkg}.built"

