# mod_wsgi
build_mod_wsgi()
{
 opt="BADCONFIGURE" \
 build_gnuconf mod_wsgi $srcdir_mod_wsgi \
                        --with-apxs="${prefix}/bin/apxs" \
                        --with-python="${prefix}/bin/python3"
 return $?
}
