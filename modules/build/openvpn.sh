# openvpn
#
build_openvpn()
{
 enable_plugin_auth_pam=no build_gnuconf openvpn $srcdir_openvpn
 return $?
}
