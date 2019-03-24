# postgresql
#
build_postgresql()
{
 [ -d "${prefix}/lib/pkgconfig" ] && export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig"
 build_gnuconf postgresql $srcdir_postgresql  \
			--disable-rpath       \
			--enable-thread-safety
 return $?
}
