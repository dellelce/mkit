# git
build_git()
{
 opt="BADCONFIGURE" \
 build_gnuconf git $srcdir_git \
          --with-zlib="${prefix}"
 return $?
}
