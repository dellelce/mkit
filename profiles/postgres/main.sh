profile_postgres()
{
# 170519 changing to openssl because:
# building with libressl fails with:
#postgresql/postgresql-11.3/src/backend/libpq/be-secure-openssl.c:1103:63: error: ‘Port’ has no member named ‘peer'’
#   strlcpy(ptr, X509_NAME_to_cstring(X509_get_subject_name(port->peer)), len);
 add_run_dep openssl
 add_run_dep libxml2
 add_run_dep zlib
 add_run_dep ncurses
 add_run_dep readline
 add_run_dep postgresql
 return $?
}
