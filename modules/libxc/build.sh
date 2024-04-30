#
# libxc
#
build_libxc()
{
 build_gnuconf libxc $srcdir_libxc --enable-shared
 return $?
}
