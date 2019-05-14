build_blender()
{
 typeset opwd="$PWD"
 cd "$srcdir_blender"

 cmake

 cd "$opwd"

 build_raw_core blender $srcdir_blender
 return $?
}
