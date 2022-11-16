# generate Makefiles with cmake/"bootstrap"

 cd ${BUILDDIR}/fluentbit
 cmake "${srcdir_fluentbit}"  -DCMAKE_INSTALL_PREFIX=${prefix} \
                              -DFLB_RECORD_ACCESSOR=Off \
                              -DFLB_STREAM_PROCESSOR=Off
