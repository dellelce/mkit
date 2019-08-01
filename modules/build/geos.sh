build_geos()
{
 [ -d "${prefix}/lib/pkgconfig" ] && export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig"

 build_gnuconf geos $srcdir_geos
 return $?
}
