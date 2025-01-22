#
# ncurses
#
build_ncurses()
{
 export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig"
 mkdir -p "$PKG_CONFIG_PATH"

 # --disable-lib-suffixes: if this is passed it won't generate ncursesw
 #                         which is needed by readline at least with default options
 build_gnuconf ncurses $srcdir_ncurses --with-shared --with-cxx-shared  \
                                       --without-ada \
                                       --enable-pc-files
 return $?
}
