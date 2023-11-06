
# cmake's configure is a wrapper to bootstrap that in turns uses cmake itself....
build_cmake()
{
 build_gnuconf cmake $srcdir_cmake -- -DOPENSSL_ROOT_DIR=${prefix}
 return $?
}
