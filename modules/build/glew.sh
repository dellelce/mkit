
#
# glew
build_glew()
{
 GLEW_DEST="${prefix}" \
 SYSTEM=linux \
 build_raw_core glew $srcdir_glew

 return $?
}
