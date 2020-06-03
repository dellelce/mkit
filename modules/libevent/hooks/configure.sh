# generate Makefiles with cmake/"bootstrap"

 cd ${BUILDDIR}/libevent
 cmake "${srcdir_libevent}"  -DCMAKE_INSTALL_PREFIX=${prefix}
