#!/bin/bash
#
# File:         mkit.config.sh
# Created:      180516
# Description:  mkit configuration (shell format)
#

### FUNCTIONS ###

### ENV ###

 SRCLIST="libffi libbsd expat sqlite3 m4 autoconf suhosin bison apr aprutil bzip2
             httpd openssl php pcre libxml2 zlib mod_wsgi readline python3 "
 export srcget="0.0.7.2"  #  srcget version

 # vt100 family sequences
 export ESC=""
 export BOLD="${ESC}[1m"
 export RESET="${ESC}[0m"

### EOF ###
