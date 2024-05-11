#
# ncurses
#
build_ncurses()
{
 export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig"
 mkdir -p "$PKG_CONFIG_PATH"

 build_gnuconf ncurses $srcdir_ncurses --with-shared --with-cxx-shared  \
                                       --without-ada --disable-lib-suffixes
 return $?
}
