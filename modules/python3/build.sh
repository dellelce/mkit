# python3
#
build_python3()
{
 typeset rc=0
 typeset fn

 [ -d "${prefix}/lib/pkgconfig" ] && export PKG_CONFIG_PATH="${prefix}/lib/pk config"

 LDFLAGS="-L${prefix}/lib -Wl,-rpath=${prefix}/lib"  \
 CFLAGS="-I${prefix}/include"                        \
 build_gnuconf python3 $srcdir_python3 \
            --with-openssl="${prefix}" \
            --enable-shared \
            --with-system-expat \
            --with-system-ffi   \
            --with-ensurepip=yes
 rc=$?

 # remove all .a files
 # note: the following line could fail if any filename as a "space", can this happen?
 find $prefix -type f -name '*\.a' | xargs rm

 return $rc
}
