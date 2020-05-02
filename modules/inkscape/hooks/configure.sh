# generate Makefiles with cmake/"bootstrap"

 cd ${BUILDDIR}/inkscape
 cmake "${srcdir_inkscape}"  -DCMAKE_INSTALL_PREFIX=${prefix}
