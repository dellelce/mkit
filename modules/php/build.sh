# php
#
build_php()
{
 build_gnuconf php $srcdir_php \
                 --enable-shared \
                 --with-libxml-dir=${prefix} \
                 --with-openssl=${prefix} \
                 --with-openssl-dir="${prefix}"     \
                 --with-apxs2="${prefix}/bin/apxs"
 return $?
}
