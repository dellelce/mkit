build_mesa3d()
{
 [ -d "${prefix}/lib/pkgconfig" ] && export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig"
 build_gnuconf mesa3d $srcdir_mesa3d --enable-autotools \
                                     --with-gallium-drivers=svga
 return $?
}
