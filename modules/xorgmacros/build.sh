build_xorgmacros()
{
 typeset rc=$?

 [ -d "${prefix}/lib/pkgconfig" ] && export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig"

 build_gnuconf xorgmacros $srcdir_xorgmacros 
 rc=$?

 [ -f "${prefix}/share/pkgconfig/xorg-macros.pc" ] &&
 {
  mkdir -p "${prefix}/lib/pkgconfig"
  cp "${prefix}/share/pkgconfig/xorg-macros.pc" "${prefix}/lib/pkgconfig/xorg-macros.pc"
 }

 return $rc
}
