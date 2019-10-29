# generate Makefiles with cmake/"bootstrap"

 cd ${BUILDDIR}/geant4
 cmake "${srcdir_geant4}"  -DCMAKE_INSTALL_PREFIX=${prefix}
