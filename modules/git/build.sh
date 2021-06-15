# git
build_git()
{
 typeset extra_opts=""

 type tclsh >/dev/null 2>&1

 [ $? -eq 1 ] && { extra_opts="${etxra_opts} --without-tcltk"; }

 opt="BADCONFIGURE" \
 build_gnuconf git $srcdir_git \
          --with-zlib="${prefix}" ${extra_opts}
 return $?
}
