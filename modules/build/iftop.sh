#
# iftop
#
build_iftop()
{
 BASE_CFLAGS="-I${prefix}/include/ncurses" \
 opt="BADCONFIGURE" \
 build_gnuconf iftop $srcdir_iftop --with-libpcap=${prefix}
 return $?
}
