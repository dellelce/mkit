build_mesa3d()
{
 typeset rc_pip
# typeset vnw_screen_h="$srcdir_mesa3d/src/gallium/winsys/svga/drm/vmw_screen.h"
 [ -d "${prefix}/lib/pkgconfig" ] && export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig"

 # patch an issue that is exposed on alpine, already fixed on master, but still failing in 19.0.6
#[ $(grep -c "sys/types.h" "${vnw_screen_h}") -eq 0 ] &&
# {

#  typeset last_include=$(awk '/#include/ { pos=FNR; } END { print pos; } ' "${vnw_screen_h}")

#  sed -i -e "${last_include} i \
##include <sys/types.h>" "${vnw_screen_h}"
# }

 [ -z "$VIRTUAL_ENV" ] &&
 {
  local_venv="/tmp/venv_$RANDOM"

  mkdir "$local_venv" && python3 -m venv "$local_venv" && . "$local_venv/bin/activate"
  [ $? -ne 0 ] && return 1
 }

 logFile=$(logger_file ${id}_virtualenv)
 echo "Preparing virtualenv..."
 pip3 install scikit_build meson ninja > ${logFile} 2>&1

 rc_pip=$?;  [ "$rc_pip" -ne 0 ] && { cat "${logFile}"; return "$rc_pip"; }


 #meson setup --buildtype releasea --prefix



 #build_gnuconf mesa3d $srcdir_mesa3d --enable-autotools \
 #                                    --with-gallium-drivers=svga


 [ -d "$local_venv" ] &&
 {
   rm -rf "$local_venv"
 }
 return $?
}
