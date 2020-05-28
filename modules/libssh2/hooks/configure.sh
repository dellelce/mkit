# generate Makefiles with cmake/"bootstrap"

 cd ${BUILDDIR}/libssh2
 cmake "${srcdir_libssh2}"  -DCMAKE_INSTALL_PREFIX=${prefix}
