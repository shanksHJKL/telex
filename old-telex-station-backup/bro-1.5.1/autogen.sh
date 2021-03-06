#!/bin/sh

# Initialization script to set up the initial configuration files etc.
# shtool usage inspired by the autogen script of the ferite scripting
# language -- cheers Chris :)
#
# This is 'borrowed' from netdude, with minor changes for bro 

BLD_ON=`./shtool echo -n -e %B`
BLD_OFF=`./shtool echo -n -e %b`

srcdir=`dirname $0`
NAME=bro

DIE=0

echo
echo "               "${BLD_ON}"BRO Build Tools Setup"${BLD_OFF}
echo "===================================================="
echo
echo "Checking whether we have all tools available ..."

(autoconf --version) < /dev/null > /dev/null 2>&1 || {
  echo
  echo ${BLD_ON}"Error"${BLD_OFF}": You must have \`autoconf' installed to."
  echo "Download the appropriate package for your distribution,"
  echo "or get the source tarball at ftp://ftp.gnu.org/pub/gnu/"
  DIE=1
}

(automake --version) < /dev/null > /dev/null 2>&1 || {
  echo
  echo ${BLD_ON}"Error"${BLD_OFF}": You must have \`automake' installed."
  echo "Get ftp://ftp.gnu.org/pub/gnu/automake-1.3.tar.gz"
  echo "(or a newer version if it is available)"
  DIE=1
  NO_AUTOMAKE=yes
}

# if no automake, don't bother testing for aclocal
test -n "$NO_AUTOMAKE" || (aclocal --version) < /dev/null > /dev/null 2>&1 || {
  echo
  echo ${BLD_ON}"Error"${BLD_OFF}": Missing \`aclocal'.  The version of \`automake'"
  echo "installed doesn't appear recent enough."
  echo "Get ftp://ftp.gnu.org/pub/gnu/automake-1.3.tar.gz"
  echo "(or a newer version if it is available)"
  DIE=1
}

if test "$DIE" -eq 1; then
  exit 1
fi

echo "All necessary tools found."
echo

if [ -d autom4te.cache ] ; then
    echo "Removing autom4te.cache ..."
    rm -rf autom4te.cache
    #echo
    #echo ${BLD_ON}"Error"${BLD_OFF}": autom4te.cache directory exists"
    #echo "please remove it, and rerun this script"
    #echo 
    #exit 1
fi

echo
echo "running "${BLD_ON}"aclocal"${BLD_OFF}
echo "----------------------------------------------------"
aclocal -I . $ACLOCAL_FLAGS
if [ $? -ne 0 ]; then
    echo "*** ERROR($NAME), aborting."
    exit 1
fi

echo
echo "running "${BLD_ON}"autoheader"${BLD_OFF}
echo "----------------------------------------------------"
autoheader
if [ $? -ne 0 ]; then
    echo "*** ERROR($NAME), aborting."
    exit 1
fi

echo
echo "running "${BLD_ON}"automake"${BLD_OFF}
echo "----------------------------------------------------"
automake -a -c 
if [ $? -ne 0 ]; then
    echo "*** ERROR($NAME), aborting."
    exit 1
fi

echo
echo "running "${BLD_ON}"autoconf"${BLD_OFF}
echo "----------------------------------------------------"
autoconf
if [ $? -ne 0 ]; then
    echo "*** ERROR($NAME), aborting."
    exit 1
fi

echo
echo
echo "Running aux/binpac/autogen.sh"
echo "----------------------------------------------------"
(cd aux/binpac/ && BROBUILD=yes ./autogen.sh)
if [ $? -ne 0 ]; then
    echo "*** ERROR($NAME), aborting."
    exit 1
fi

echo
echo
echo "Running aux/broccoli/autogen.sh"
echo "----------------------------------------------------"
(cd aux/broccoli/ && BROBUILD=yes ./autogen.sh)
if [ $? -ne 0 ]; then
    echo "*** ERROR($NAME), aborting."
    exit 1
fi

echo
echo
echo "Running aux/broctl/aux/capstats/autogen.sh"
echo "----------------------------------------------------"
(cd aux/broctl/aux/capstats && ./autogen.sh)
if [ $? -ne 0 ]; then
    echo "*** ERROR($NAME), aborting."
    exit 1
fi

echo
echo 
echo "Setup finished. Now run:"
echo
echo "  $ "${BLD_ON}"./configure"${BLD_OFF}" (with options as needed, try --help)"
echo
echo "and then"
echo
echo "  $ "${BLD_ON}"make"${BLD_OFF}
echo "  # "${BLD_ON}"make install"${BLD_OFF}
echo
