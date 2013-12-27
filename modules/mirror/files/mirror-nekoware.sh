#!/bin/sh

home=${1}

cd ${home}

. ${home}/mirror.conf

rsync -ralp --delete --no-motd ${NEKOWARE_MIRROR}/ ${TOPLEVEL}/nekoware/
