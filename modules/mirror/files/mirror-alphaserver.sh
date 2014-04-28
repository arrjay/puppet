#!/bin/sh

home=${1}

cd ${home}

. ${home}/mirror.conf

mkdir -p ${ARCHIVEDIR}/alphaserver/
# firmware for 164lx
alphapc_fw=alphaserver/firmware/retired_platforms/alphapc/
mkdir -p ${ARCHIVEDIR}/${alphapc_fw}
ncftpget -R -f ${home}/ncftp/hp.cfg ${ARCHIVEDIR}/${alphapc_fw} pub/${alphapc_fw}alphapc164lx
