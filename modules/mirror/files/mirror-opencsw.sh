#!/bin/sh

home=${1}

cd ${home}

. ${home}/mirror.conf

mkdir -p ${TOPLEVEL}/opencsw/stable/
rsync -ralp --delete --no-motd ${OPENCSW_MIRROR}/stable/ ${TOPLEVEL}/opencsw/stable/

cd ${TOPLEVEL}/opencsw

trimtrees.pl . > /dev/null
