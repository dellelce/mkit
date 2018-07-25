#!/bin/bash
#
# Building for travis
#
# File:         travis.sh
# Created:      250718
#

### ENV ###

prefix="$1"
python="$prefix/bin/python3"

### MAIN ###

mkdir $prefix && ./mkit.sh $prefix
rc=$?

echo "mkit rc: $rc"

# even if rc != 0: we do some tests anyway

[ -x "$python" ] &&
{
 echo "Testing correct OpenSSL is built:"
 echo "import _ssl; print(_ssl.OPENSSL_VERSION);" | ${python}
} ||
{
 echo "No python executable!!"
}

#
echo
ls -lt "${prefix}/bin"

exit $rc

### EOF ###
