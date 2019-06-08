build_mesa3d()
{
 [ -d "${prefix}/lib/pkgconfig" ] && export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig"

 # patch an issue that is exposed on alpine, already fixed on master, but still failing in 19.0.6
 [ $(grep -c "sys/types.h" $srcdir_mesa3d/src/gallium/winsys/svga/drm/vmw_screen.h) -eq 0 ] &&
 {
  typeset last_include=$(awk '/#include/ { pos=FNR; } END { print pos; } ')

  sed -i -e "${last_include} i \
#include <sys/types.h>" $srcdir_mesa3d/src/gallium/winsys/svga/drm/vmw_screen.h
 }

 build_gnuconf mesa3d $srcdir_mesa3d --enable-autotools \
                                     --with-gallium-drivers=svga
 return $?
}
