# python3
#
build_python3()
{
 typeset rc=0
 typeset fn

 LDFLAGS="-L${prefix}/lib -Wl,-rpath=${prefix}/lib"  \
 CFLAGS="-I${prefix}/include"                        \
 build_gnuconf python3 $srcdir_python3 \
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
