build_xxf86vm()
{
 [ -d "${prefix}/lib/pkgconfig" ] && export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig"
 build_gnuconf xxf86vm $srcdir_xxf86vm
 return $?
}
