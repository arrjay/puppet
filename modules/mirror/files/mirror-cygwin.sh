#!/bin/sh

home=${1}

cd ${home}

. ${home}/mirror.conf

rsync -ralp --delete ${CYGWIN_MIRROR}/ ${TOPLEVEL}/cygwin/

cd ${TOPLEVEL}/cygwin

trimtrees.pl . > /dev/null
