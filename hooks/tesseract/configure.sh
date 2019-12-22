# generate Makefiles with cmake

 cd ${BUILDDIR}/tesseract
 cmake "${srcdir_tesseract}"  -DCMAKE_INSTALL_PREFIX=${prefix}
