build_xorgmacros()
{
 typeset rc=$?

 [ -d "${prefix}/lib/pkgconfig" ] && export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig"

 #cd "${srcdir_xorgmacros}"
 #./autogen.sh && ./configure --prefix=${prefix}  && make && make install
 build_gnuconf xorgmacros $srcdir_xorgmacros 
 rc=$?

 [ -f "${prefix}/share/pkgconfig/xorg-macros.pc" ] &&
 {
  cp "${prefix}/share/pkgconfig/xorg-macros.pc" "${prefix}/lib/pkgconfig/xorg-macros.pc"
 }

 return $rc
}
