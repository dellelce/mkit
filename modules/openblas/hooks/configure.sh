# generate Makefiles with cmake/"bootstrap"

 cd ${BUILDDIR}/openblas
 cmake "${srcdir_openblas}"  -DCMAKE_INSTALL_PREFIX=${prefix}
