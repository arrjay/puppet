#!/bin/sh

home=${1}

cd ${home}

. ${home}/mirror.conf

mkdir -p ${ARCHIVEDIR}/alphant/
ncftpget -R -f ${home}/ncftp/hp.cfg ${ARCHIVEDIR}/ ftp1/pub/softpaq/alphant/
