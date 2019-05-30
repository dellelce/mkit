build_damageproto()
{
 [ -d "${prefix}/lib/pkgconfig" ] && export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig"; build_gnuconf damageproto $srcdir_damageproto 
 return $?
}
