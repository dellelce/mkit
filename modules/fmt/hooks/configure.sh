# generate Makefiles with cmake/"bootstrap"

 cd ${BUILDDIR}/fmt
 cmake "${srcdir_fmt}"  -DCMAKE_INSTALL_PREFIX=${prefix} 
