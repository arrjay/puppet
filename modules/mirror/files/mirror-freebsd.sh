#!/bin/sh

home=${1}

cd ${home}

. ${home}/mirror.conf

for ver in ${FREEBSD_VERSIONS} ; do
  for arch in ${FREEBSD_ARCHITECTURES} ; do
    mkdir -p ${TOPLEVEL}/FreeBSD/releases/${arch}/${ver}/
    # ncftp makes ${ver}... or rather, the last directory specified.
    ncftpget -R -f ${home}ncftp/freebsd.cfg ${TOPLEVEL}/FreeBSD/releases/${arch}/ pub/FreeBSD/releases/${arch}/${ver}/
  done
done
