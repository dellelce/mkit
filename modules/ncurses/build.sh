#
# ncurses
#
build_ncurses()
{
 build_gnuconf ncurses $srcdir_ncurses --with-shared --with-cxx-shared  \
                                       --without-ada --disable-lib-suffixes
 return $?
}
