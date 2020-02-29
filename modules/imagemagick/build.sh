#
# imagemagick
#
build_imagemagick()
{
 [ -d "${prefix}/lib/pkgconfig" ] && export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig"
 build_gnuconf imagemagick $srcdir_imagemagick
 return $?
}
