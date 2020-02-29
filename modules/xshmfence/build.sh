build_xshmfence()
{
 [ -d "${prefix}/lib/pkgconfig" ] && export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig"

 build_gnuconf xshmfence $srcdir_xshmfence 
 return $?
}
