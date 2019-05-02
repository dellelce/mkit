#
# flex
#
build_flex()
{
 ac_cv_path_HELP2MAN=: \
 HELP2MAN=: MAKEINFO=: \
 build_gnuconf flex $srcdir_flex
 return $?
}
