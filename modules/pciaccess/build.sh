build_pciaccess()
{
 [ -d "${prefix}/lib/pkgconfig" ] && export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig"
 build_gnuconf pciaccess $srcdir_pciaccess

 return $?
}
