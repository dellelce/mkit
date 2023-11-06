build_xtrans()
{
 typeset rc

 [ -d "${prefix}/lib/pkgconfig" ] && export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig"]

 build_gnuconf xtrans $srcdir_xtrans; rc=$?

 [ -f "${prefix}/share/pkgconfig/xtrans.pc" ] &&
 {
  cp "${prefix}/share/pkgconfig/xtrans.pc" "${prefix}/lib/pkgconfig/xtrans.pc"
 }

 return $rc
}
