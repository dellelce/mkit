#
# GNU TLS library
build_gnutls()
{
 build_gnuconf gnutls $srcdir_gnutls
 return $?
}
