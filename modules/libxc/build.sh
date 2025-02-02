#
# libxc
#
build_libxc()
{
 build_gnuconf libxc $srcdir_libxc --enable-shared \
                      --disable-fortran --disable-kxc --disable-lxc; rc=$?

 return $rc
}
