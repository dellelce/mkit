# APR-Util
#
build_aprutil()
{
 # both crypto/openssl & sqlite3 do not appear to work (link) with the following options.... ignoring for now
 #build_gnuconf aprutil $srcdir_aprutil --with-apr="${prefix}" \
 #                   --with-openssl="${prefix}" --with-crypto \
 #                    --with-sqlite3="${prefix}" \
 #                  --with-apr="${prefix}" # --with-openssl="${prefix}" --with-crypto
 build_gnuconf aprutil $srcdir_aprutil \
                       --with-apr="${prefix}"
 return $?
}
