# generate Makefiles with cmake/"bootstrap"

 cd ${BUILDDIR}/libgit2
 cmake "${srcdir_libgit2}"  -DCMAKE_INSTALL_PREFIX=${prefix}
