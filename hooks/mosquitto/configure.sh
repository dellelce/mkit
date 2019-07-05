# generate Makefiles with cmake/"bootstrap"

 cd ${BUILDDIR}/mosquitto
 cmake "${srcdir_mosquitto}"  -DCMAKE_INSTALL_PREFIX=${prefix}
