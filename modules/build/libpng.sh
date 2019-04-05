#
# libpng
#
build_libpng()
{
 # our CFLAGS is overwritten or "ignored" by libpng
 export CPPFLAGS="${CFLAGS}"
 build_gnuconf libpng $srcdir_libpng \
				--with-zlib-prefix=${prefix} \
                                --includedir=${prefix}/include
 return $?
}
