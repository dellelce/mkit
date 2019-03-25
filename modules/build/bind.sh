#
# bind
#
build_bind()
{
 ${prefix}/bin/pip3 install ply
 build_gnuconf bind $srcdir_bind  --with-openssl=${prefix} \
				  --disable-linux-caps
 return $?
}
