profile_opengl()
{
 #gnubuild to be used with alpine 3.9 or should we just check for pkgconf(ig)
 #profile_gnubuild

 #xcbproto has some python code...
 profile_pythonbuild
 add_run_dep dri2proto
 add_run_dep glproto
 add_run_dep pciaccess
 add_run_dep libdrm
 add_run_dep xproto
 add_run_dep xextproto
 add_run_dep xtrans
 add_run_dep kbproto
 add_run_dep inputproto
 add_run_dep xcbproto
 add_run_dep pthreadstubs
 add_run_dep xau
 add_run_dep xcb
 add_run_dep x11
 add_run_dep damageproto
 add_run_dep fixesproto
 add_run_dep xfixes
 add_run_dep xdamage
 add_run_dep xext
 add_run_dep xf86vidmodeproto
 add_run_dep xxf86vm
 add_run_dep xorgmacros
 add_run_dep xshmfence
 add_run_dep randrproto
 add_run_dep renderproto
 add_run_dep libxrender
 add_run_dep libxrandr
 add_run_dep xrandr
 add_run_dep expat2_1
 add_run_dep zlib

 #travis: currently building mesa3d exceeds 10 minutes and travil kills the process because nothing is sent to stdout
 #        this is a bit "excessive" but we want to hog almost all processors available
 typeset cpucnt=$(egrep -c '^processor' /proc/cpuinfo)
 [ $cpucnt -eq 2 ] && add_make_options mesa3d -j${cpucnt}
 [ $cpucnt -gt 2 ] && { let cpucnt="(( $cpucnt - 1 ))";  add_make_options mesa3d -j${cpucnt}; }
 add_run_dep mesa3d
}
