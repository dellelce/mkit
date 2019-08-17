
#
# opencsg
build_opencsg()
{
 # sanity check: add "standard" flags if missing
 [ -z "$CFLAGS" ] && export CFLAGS="-I${prefix}/include"
 [ -z "$CXXFLAGS" ] && export CXXFLAGS="-I${prefix}/include"
 [ -z "$LDFLAGS" ] && export LDFLAGS="-L${prefix}/lib -Wl,-rpath=${prefix}/lib"
 _LDFLAGS="${LDFLAGS}"


 # Disable build of example
 sed -E -i 's/make_default: sub-src-make_default sub-example-make_default FORCE/make_default: sub-src-make_default/' \
                                  $srcdir_opencsg/Makefile
 sed -E -i 's/install: install_subtargets  FORCE/install: sub-src-install_subtargets/' \
                                  $srcdir_opencsg/Makefile

 # Patch Makefile so it accesses dependencies in out paths.
 sed -E -i 's/^CFLAGS(.*)/CFLAGS\1 $(_CFLAGS)/' $srcdir_opencsg/src/Makefile
 sed -E -i 's/^CXXFLAGS(.*)/CXXFLAGS\1 $(_CXXFLAGS)/' $srcdir_opencsg/src/Makefile

 sed -E -i 's/^LIBS(.*)-lGLEW -lGL(.*)/LIBS\1 $(_LDFLAGS) -lGLEW -lGL\2/' $srcdir_opencsg/src/Makefile

 _CFLAGS="${CFLAGS}" \
 _CXXFLAGS="${CXXFLAGS}" \
 _LDFLAGS="${LDFLAGS}" \
 build_raw_core opencsg $srcdir_opencsg

 return $?
}
