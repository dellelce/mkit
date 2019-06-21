
#
# opencsg
build_opencsg()
{
 # Patch Makefile so it accesses dependencies in out paths.
 sed -E -i 's/^CFLAGS(.*)/CFLAGS\1 $(_CFLAGS)/' $srcdir_opencsg/src/Makefile
 sed -E -i 's/^CXXFLAGS(.*)/CXXFLAGS\1 $(_CXXFLAGS)/' $srcdir_opencsg/src/Makefile
 sed -E -i 's/^LIBS(.*)/LIBS\1 $(_LDLAGS)/' $srcdir_opencsg/src/Makefile

 # sanity check: add "standard" flags if missing
 [ -z "$CFLAGS" ] && export CFLAGS="-I${prefix}/include"
 [ -z "$CXXFLAGS" ] && export CXXFLAGS="-I${prefix}/include"
 [ -z "$LDFLAGS" ] && export LDFLAGS="-L${prefix}/lib -Wl,-rpath=${prefix}/lib"

 _CFLAGS="${CFLAGS}" \
 _CXXFLAGS="${CXXFLAGS}" \
 _LDFLAGS="${LDFLAFS}" \
 build_raw_core opencsg $srcdir_opencsg

 return $?
}
