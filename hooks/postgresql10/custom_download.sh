
# add support for downloading postgresql from custom commit
[ ! -z "$pgcommit" ] &&
{
 commit="${pgcommit}"
 fname="$PWD/pg10-${commit}.tar.gz"
 ghpath="postgres/postgres"
 fullurl="https://github.com/${ghpath}/archive/${commit}.tar.gz"
 wget -q -O "$fname" "$fullurl"
 rc=$?

 [ -f "$fname" ] && echo "$fname"

 exit $rc
}

exit 0
