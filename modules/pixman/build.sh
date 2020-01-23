#
# pixman
#
build_pixman()
{
 [ -d "${prefix}/lib/pkgconfig" ] && export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig"
 build_gnuconf pixman $srcdir_pixman
 return $?
}
