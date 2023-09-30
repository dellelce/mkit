build_libtiff()
{
 [ -d "${prefix}/lib/pkgconfig" ] && export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig";

 build_gnuconf libtiff $srcdir_libtiff
 return $?
}
