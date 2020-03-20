# python2
#
build_python2()
{
 typeset rc=0
 typeset fn

 LDFLAGS="-L${prefix}/lib -Wl,-rpath=${prefix}/lib"  \
 CFLAGS="-I${prefix}/include"                        \
 build_gnuconf python2 $srcdir_python2 \
            --with-openssl="${prefix}" \
            --enable-shared \
            --with-system-expat \
            --with-system-ffi   \
            --with-ensurepip=yes
 rc=$?

 # remove this file until I have proof I need it ;)
 # is it for building modules? Not clear in Makefile's "libainstall" target
 for fn in $prefix/lib/python*/config-*/lib*.a
 do
   [ -f "$fn" ] && rm -f "$fn"
 done

 return $rc
}
