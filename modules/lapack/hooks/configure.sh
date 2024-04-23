# generate Makefiles with cmake/"bootstrap"

 cd ${BUILDDIR}/lapack
 cmake "${srcdir_lapack}"  -DCMAKE_INSTALL_PREFIX=${prefix}
