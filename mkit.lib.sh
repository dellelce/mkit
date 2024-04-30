#!/bin/bash
#
# mkit core library
#

# get perl versions as variables
getPerlVersions()
{
 typeset perlBin="perl"

 type ${perlBin} 2>/dev/null && return $?

 ${perlBin} -V | awk '
FNR == 1 \
{
 gsub(/[()]/, " ");

 cnt = split($0, a);
 last = "" # state variable

 for(idx in a)
 {
  item = a[idx]

  if (item == "revision" || item == "version" || item == "subversion")
  {
   last = item
   continue
  }

  if (last == "revision")   { revision = item;   last = ""; continue; }
  if (last == "version")    { version = item;    last = ""; continue; }
  if (last == "subversion") { subversion = item; last = ""; continue; }
 }
}

END \
{
  printf("export PERL_REVISION=\"%s\";",   revision);
  printf("export PERL_VERSION=\"%s\";",    version);
  printf("export PERL_SUBVERSION=\"%s\";", subversion);
}
'
#Summary of my perl5  revision 5 version 22 subversion 2  configuration:
}

# download srcget
get_srcget()
{
 wget -q -O ${srcget}.tar.gz               \
            "${srcgetUrl}/${srcget}.tar.gz" || return 1

 tar xzf ${srcget}.tar.gz  || return 2
 rm -f srcget
 ln -s srcget-${srcget} srcget
 export PATH="$PWD/srcget:$PATH"
}

# wrapper to srcget.sh, for now
get_source()
{
 srcget.sh -n $*
}

# download
#
# Used Globals:
#   DOWNLOADS
#   DOWNLOAD_MAP
#   RUNTIME_LIST
#   BUILDTIME_LIST
download()
{
 typeset pkg fn
 typeset wd="$PWD"
 export DOWNLOAD_MAP=""

 cd "$DOWNLOADS" || return $?

 for pkg in $RUNTIME_LIST
 do
  typeset dont_download=$(hook $pkg dont_download)

  [ ! -z "$dont_download" ] && continue

  typeset custom_download=$(hook $pkg custom_download)

  [ -f "$custom_download" ] &&
  {
   fn="$custom_download"
   echo "${BOLD}$pkg${RESET} has been \"custom\" downloaded as: " $fn
  } ||
  {
   fn=$(get_source $pkg)
   srcget_rc=$?
   [ -z "$fn" ] && { echo "Invalid filename"; return $srcget_rc; }

   [ $srcget_rc -eq 8 ] &&
   {
     # Debug error code 8: "Not Found"

     get_source -x $pkg
   }

   fn="$PWD/$fn"
   [ ! -f "$fn" ] && { echo "Failed downloading $pkg: rc = $srcget_rc"; return $srcget_rc; }
  }
  echo "${BOLD}$pkg${RESET} has been downloaded as: " $fn

  DOWNLOAD_MAP="${DOWNLOAD_MAP} ${pkg}:${fn}"  # this will fail if ${fn} has spaces!

  # save directory to a variable named after the package
  eval "fn_${pkg}=$fn"
 done

 # build-time packages need only be downloaded if not already installed
 for pkg in $BUILDTIME_LIST
 do
  # if hook does not exist the package has to be downloaded as there is nothing to check
  # (hook function returns always zero if hook does no exist!)
  have_hook $pkg is_installed
  typeset is_installed_state=$?

  [ $is_installed_state -eq 0 ] && hook $pkg is_installed &&
  {
   INSTALLED_LIST="$INSTALLED_LIST $pkg";
   eval "fn_${pkg}=installed"
   echo "${BOLD}$pkg${RESET} is a build-time dependency and is already installed."
   continue
  }

  typeset custom_download=$(hook $pkg custom_download)

  [ -f "$custom_download" ] &&
  {
   fn="$custom_download"
   echo "${BOLD}$pkg${RESET} has been \"custom\" downloaded as: " $fn
  } ||
  {
   fn=$(get_source $pkg)
   srcget_rc=$?
   fn="$PWD/$fn"

   [ $srcget_rc -eq 8 ] &&
   {
     # Debug error code 8: "Not Found"

     get_source -x $pkg
   }

   [ ! -f "$fn" ] && { echo "Failed downloading $pkg: rc = $srcget_rc"; return $srcget_rc; }

   echo "${BOLD}$pkg${RESET} has been downloaded as: " $fn
  }

  DOWNLOAD_MAP="${DOWNLOAD_MAP} ${pkg}:${fn}"  # this will fail if ${fn} has spaces!

  # save directory to a variable named after the package
  eval "fn_${pkg}=$fn"
 done

 cd "$wd"
}

# get filename for given package
#
getfilename()
{
 typeset pkg="$1"; [ -z "$pkg" ] && return 1

 eval echo "\$fn_${pkg}"
}

# get base filename for given package
#
getbasename()
{
 typeset pkg="$1"; [ -z "$pkg" ] && return 1

 eval basename "\$fn_${pkg}"
}

# xz handler
un_xz()
{
 typeset fn="$1" rc=0 dir=""; shift
 typeset bdir="$1"

 [ ! -f "$fn" ] && { echo "uncompress: $fn is not a file."; return 1; }

 xz -dc < "${fn}" | tar xf - -C "${bdir}"
 rc=$?
 [ "$rc" -eq 0 ] &&
 {
  dir=$(ls -d1t ${bdir}/* | head -1)
  [ -d "$dir" ] && echo $dir
  return 0
 }

 echo "un_xz return code: $rc"
 return $rc
}

#
# bz2 handler
un_bz2()
{
 typeset fn="$1" rc=0 dir=""; shift
 typeset bdir="$*"

 [ ! -f "$fn" ] && return 1

 tar xjf  "${fn}" -C "${bdir}"
 rc=$?
 [ "$rc" -eq 0 ] &&
 {
  dir=$(ls -d1t ${bdir}/* | head -1)
  [ -d "$dir" ] && echo $dir
  return 0
 }

 echo "un_bz2 return code: $rc"
 return $rc
}

#
# gz
#
un_gz()
{
 typeset fn="$1" rc=0 dir=""; shift
 typeset bdir="$*"

 [ ! -f "$fn" ] && return 1

 tar xzf "${fn}" -C "${bdir}"
 rc=$?
 [ "$rc" -eq 0 ] && { dir=$(ls -d1t ${bdir}/* | head -1); [ -d "$dir" ] && echo $dir; return 0; }

 echo "un_gz return code: $rc"
 return $rc
}

#
#
save_srcdir()
{
 typeset id="$1"
 typeset dir="$2"

 [ -d "$dir" ] && { eval "export srcdir_${id}=${dir}"; return 0; }

 echo "save_srcdir: $dir is not a directory."
 return 1
}

# generic wrapper for uncompress
# TODO: these two functions may be merged?
do_uncompress ()
{
 typeset id=$1;
 eval  "fn=\$fn_$id";
 uncompress $id $fn || { echo "Failed uncompress for: $fn_$id"; return 1; }

 eval  "hook_srcdir=\$srcdir_$id";
 hook global after_download $hook_srcdir
 hook $id    after_download $hook_srcdir

 return 0
}

#
#
uncompress()
{
 typeset id="$1"
 typeset fn="$2"
 typeset bdir="${SRCDIR}/${id}"

 [ ! -f "$fn" ] && { echo "Invalid file name: $fn"; return 1; }
 mkdir -p "$bdir"

 [ "$fn" != "${fn%.xz}" ] && { dir=$(un_xz "${fn}" "${bdir}"); save_srcdir $id $dir; return $?; }
 [ "$fn" != "${fn%.bz2}" ] && { dir=$(un_bz2 "${fn}" "${bdir}"); save_srcdir $id $dir; return $?; }
 [ "$fn" != "${fn%.tgz}" ] && { dir=$(un_gz "${fn}" "${bdir}"); save_srcdir $id $dir; return $?; }
 [ "$fn" != "${fn%.gz}" ] && { dir=$(un_gz "${fn}" "${bdir}"); save_srcdir $id $dir; return $?; }

 echo "uncompress: Can't handle $fn type"
 return 1
}

# autotools/automake require recent perl
test_perl_automake()
{
 eval $(getPerlVersions)

 [ "$PERL_REVISION" -eq 5 -a "$PERL_VERSION" -lt 10 ] &&
 {
  add_build_dep perl
  export PERL_NEEDED=1
  cat << EOF
   Detected version of perl is ${PERL_REVISION}.${PERL_VERSION}.${PERL_SUBVERSION} minimum required version is 5.10.
   Will download and build local version.

EOF
 }
}

# have_hook: check if given hook exists
have_hook()
{
 # package name, hook name
 typeset pname="$1"; shift
 typeset hname="$1"; shift

 typeset hookfile="$MKIT/modules/$pname/hooks/${hname}.sh"

 [ -f "$hookfile" ] && { return 0; } || { return 1; }
}

# hook: run a "piece of code" associated with a certain step & package
hook()
{
 # package name, hook name, arguments
 typeset pname="$1"; shift
 typeset hname="$1"; shift
 typeset args="$*"; shift

 typeset hookfile="$MKIT/modules/$pname/hooks/${hname}.sh"

 [ -f "$hookfile" ] &&
 {
  $SHELL "$hookfile" $args
  return $?
 }

 return 0
}

### EOF ###
