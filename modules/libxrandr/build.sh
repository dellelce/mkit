build_libxrandr()
{
 [ -d "${prefix}/lib/pkgconfig" ] && export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig"

 build_gnuconf libxrandr $srcdir_libxrandr 
 return $?
}
