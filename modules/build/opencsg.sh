
#
# opencsg
build_opencsg()
{
 # Patch Makefile so it accesses dependencies in out paths.
 sed -E -i 's/^CFLAGS(.*)/CFLAGS\1 $(CFLAGS)/' $srcdir_opencsg/src/Makefile
 sed -E -i 's/^CXXFLAGS(.*)/CXXFLAGS\1 $(CXXFLAGS)/' $srcdir_opencsg/src/Makefile
 sed -E -i 's/^LIBS(.*)/LIBS\1 $(LDLAGS)/' $srcdir_opencsg/src/Makefile

 # sanity check: add "standard" flags if missing
 [ -z "$CFLAGS" ] && export CFLAGS="-I${prefix}/include"
 [ -z "$CXXFLAGS" ] && export CXXFLAGS="-I${prefix}/include"
 [ -z "$LDFLAGS" ] && export LDFLAGS="-L${prefix}/lib -Wl,-rpath=${prefix}/lib"

 CFLAGS="${CFLAGS}" \
 CXXFLAGS="${CFLAGS}" \
 LDFLAGS="${LDFLAFS}" \
 build_raw_core opencsg $srcdir_opencsg

 return $?
}
