#
# cairo
#
build_cairo()
{
 [ -d "${prefix}/lib/pkgconfig" ] && export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig"
 build_gnuconf cairo $srcdir_cairo
 return $?
}
