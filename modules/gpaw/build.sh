build_gpaw()
{
 [ -d "${prefix}/lib/pkgconfig" ] && export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig";

 pip3 install gpaw
 return $?
}
