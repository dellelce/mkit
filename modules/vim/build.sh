build_vim()
{
 typeset rc=0

 #[ -d "${prefix}/lib/pkgconfig" ] && export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig"]
 #rm $srcdir_vim/src/auto/configure
 #rm $srcdir_vim/src/configure

 mv $srcdir_vim/src/auto/configure $srcdir_vim/src

 sed -i -e 's/auto\///' $srcdir_vim/src/configure

 export srcdir_vim="$srcdir_vim/src"

 #BADCONFIGURE=yes \
 build_gnuconf vim $srcdir_vim  --with-tlib=ncurses; rc=$?

 return $rc
}
