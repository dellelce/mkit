build_libdrm()
{
 [ -d "${prefix}/lib/pkgconfig" ] && export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig"
 build_gnuconf libdrm $srcdir_libdrm

 return $?
}
