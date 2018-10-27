
#
# redis
build_redis()
{
 build_raw_core redis $srcdir_redis

 return $?
}
