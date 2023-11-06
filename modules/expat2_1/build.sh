build_expat2_1()
{
 [ -d "${prefix}/lib/pkgconfig" ] && export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig"
 build_gnuconf expat2_1 $srcdir_expat2_1
 return $?
}
