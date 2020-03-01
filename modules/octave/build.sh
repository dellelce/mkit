build_octave()
{
 [ -d "${prefix}/lib/pkgconfig" ] && export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig";
 build_gnuconf octave $srcdir_octave 

 return $?
}
