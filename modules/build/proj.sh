build_proj()
{
 [ -d "${prefix}/lib/pkgconfig" ] && export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig"

 build_gnuconf proj $srcdir_proj
 return $?
}
