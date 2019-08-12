build_mesa3d()
{
 # setup environment: return code variables, directory variables
 # create directories? build directory and BUILDDIR?
 typeset id="mesa3d"
 typeset dir="$srcdir_mesa3d"
 typeset pkgbuilddir="$BUILDDIR/$id"

 typeset rc_pip rc_configure rc_install

 [ -d "${prefix}/lib/pkgconfig" ] && export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig"

 local_venv="/tmp/venv_$RANDOM"

 # setup a virtualenv
 # TODO: need to handle cleanup of this
 mkdir "$local_venv" && python3 -m venv "$local_venv" && . "$local_venv/bin/activate"
 [ $? -ne 0 ] && return 1

 logFile=$(logger_file ${id}_virtualenv)
 echo "Preparing virtualenv..."
 pip3 install mako scikit_build meson ninja > ${logFile} 2>&1

 rc_pip=$?; [ "$rc_pip" -ne 0 ] && { cat "${logFile}"; return "$rc_pip"; }

 # Reference: https://www.mesa3d.org/meson.html

 cd "$dir"

 logFile=$(logger_file ${id}_configure)
 echo "Configuring"
 typeset DRI_DRIVERS=""
 typeset GALLIUM_DRV="svga,swrast"
 typeset VULKAN_DRV="auto"
 typeset PLATFORMS="x11" # leaving auto enables wayland which has a problem with PKG_CONFIG_PATH

 #configuration
 # vulkan-drivers is set explicitly to "intel" to avoid LLVM as "amd" requires LLVM.
 # if left to the default ("auto") both "intel" and "amd" are selected.
 [ $(uname -m) == "x86_64" ] && { VULKAN_DRV="intel"; }

 meson setup ${pkgbuilddir} \
             ${dir} \
             --buildtype=release \
             --prefix=$prefix    \
             -Dvulkan-drivers="$VULKAN_DRV"  \
             -Ddri-drivers="$DRI_DRIVERS"     \
             -Dgallium-drivers="$GALLIUM_DRV" \
             -Dplatforms="$PLATFORMS"         \
             -Dgallium-nine=false             \
             -Dgallium-softpipe=true          \
             -Dglx=dri                        \
             -Dllvm=false                     \
             -Dvalgrind=false      > ${logFile} 2>&1

 rc_configure=$?;  [ "$rc_configure" -ne 0 ] && { cat "${logFile}"; return "$rc_configure"; }

 # ninja: build
 logFile=$(logger_file ${id}_build)
 echo "Building"

 # Do it
 cd "${pkgbuilddir}"
 ninja > ${logFile} 2>&1

 rc_build=$?;  [ "$rc_build" -ne 0 ] && { cat "${logFile}"; return "$rc_build"; }

 # ninja: install
 cd "${pkgbuilddir}"
 logFile=$(logger_file ${id}_install)
 echo "Installing"

 ninja install > ${logFile} 2>&1

 rc_install=$?;  [ "$rc_install" -ne 0 ] && { cat "${logFile}"; return "$rc_install"; }

 deactivate
 [ -d "$local_venv" ] && { rm -rf "$local_venv"; }

 return $?
}
