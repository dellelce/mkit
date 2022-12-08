#TODO: need to check for headers & libraries as well
openssl version > /dev/null 2>&1
rc_bin=$?

rc_header=1

# minimalist check for headers but this must be expanded/improved
[ -f "/usr/include/openssl/ssl.h" ] && rc_header=0
[ -f "${prefix}/include/openssl/ssl.h" ] && rc_header=0

# we need both; this is usually needed for build so headers ARE needed!
[ "$rc_header" -eq 0 -a "$rc_bin" -eq 0 ] &&  exit 0

exit 1
