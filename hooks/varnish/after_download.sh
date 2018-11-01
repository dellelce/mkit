
src="$1"

# sanity check: do we have a directory with source as argument?
[ ! -d "$src" ] && exit 0

# the following will patch configure.ac
# but if configure is already there we don't need to do anything!
[ -f "$src/configure" ] && exit 0

echo "DEBUG: hook after_download has started"

sed -i -e \
's/AM_INIT_AUTOMAKE(\[1.11 foreign color-tests parallel-tests\])/AM_INIT_AUTOMAKE(\[1.11 foreign color-tests subdir-objects parallel-tests\])/' "$src/configure.ac"

exit $?
