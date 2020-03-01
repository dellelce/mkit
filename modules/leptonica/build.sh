build_leptonica()
{
 typeset rc=0

 [ -d "${prefix}/lib/pkgconfig" ] && export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig"]
 build_gnuconf leptonica $srcdir_leptonica; rc=$?

 return $?
}
