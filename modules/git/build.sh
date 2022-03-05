# git
build_git()
{
 typeset extra_opts=""

 type tclsh >/dev/null 2>&1

 [ $? -eq 1 ] && { extra_opts="${etxra_opts} --without-tcltk"; }

 type gettext >/dev/null 2>&1

 [ $? -eq 1 ] && export NO_GETTEXT=1

 type msgfmt >/dev/null 2>&1

 [ $? -eq 1 ] && export NO_GETTEXT=1

 opt="BADCONFIGURE" \
 build_gnuconf git $srcdir_git \
          --with-zlib="${prefix}" ${extra_opts}
 return $?
}
