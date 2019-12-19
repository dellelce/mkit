build_fixesproto()
{
 [ -d "${prefix}/lib/pkgconfig" ] && export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig"; build_gnuconf fixesproto $srcdir_fixesproto 
 return $?
}
