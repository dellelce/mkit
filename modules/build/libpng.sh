#
# libpng
#
build_libpng()
{
 # our CFLAGS is "ignored" by libpng .c -> .out Makefile rule
 export CPPFLAGS="${CFLAGS}"
 build_gnuconf libpng $srcdir_libpng \
				--with-zlib-prefix=${prefix} \
                                --includedir=${prefix}/include
 unset CPPFLAGS # may not be useful outside libpng
 return $?
}
