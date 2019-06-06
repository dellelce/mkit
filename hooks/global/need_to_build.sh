
#
pkg="$1"; [ -z "$pkg" ] && exit 1
[ -f "$WORKDIR/state/${pkg}.built" ] && { echo "$pkg already built."; exit 1; }
exit 0

