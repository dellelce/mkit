#
# readline
#
build_readline()
{
 export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig"
 mkdir -p "$PKG_CONFIG_PATH"

 [ -f "/etc/alpine-release" -a -f "$srcdir_readline/shlib/Makefile.in" ] &&
 {
   rlmk="$srcdir_readline/shlib/Makefile.in"

   typeset ncurses="-L${prefix}\/lib -lncurses"
   sed -i -e "s:SHLIB_LIBS = @SHLIB_LIBS@:SHLIB_LIBS = @SHLIB_LIBS@ ${ncurses}:" $rlmk
   #ls -lt $rlmk

   # commenting until a proper option for debugging is added
   #echo "Debug: lib in install target"
   #ls -lt "$prefix/lib/"
 }

 build_gnuconf readline $srcdir_readline
 return $?
}
