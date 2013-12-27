#!/bin/bash

# This script is more a historical note. I highly suggest not running it through cron (wget will loop)

home=${1}

cd ${home}

. ${home}/mirror.conf

# fetch
CL_MIRROR="stat.case.edu/mirrors/cygwin"
wget -mk --random-wait --wait 3 -nH --cut-dirs=3 --reject="index.html*" --no-parent -P ${ARCHIVEDIR}/cygwin/release-legacy http://${CL_MIRROR}/release-legacy/
cd ${ARCHIVEDIR}/cygwin
wget http://${CL_MIRROR}/setup-legacy.bz2
wget http://${CL_MIRROR}/setup-legacy.bz2.sig
wget http://stat.case.edu/mirrors/cygwin/setup-legacy.ini
wget http://stat.case.edu/mirrors/cygwin/setup-legacy.ini.sig
# the installer, for $reasons, is *here*
wget ftp://www.fruitbat.org/pub/cygwin/setup/legacy/setup-legacy.exe

# verify
for x in $(find ${ARCHIVEDIR}/cygwin/release-legacy -name md5.sum -exec dirname {} \;);do (cd $x >/dev/null && gmd5sum -c md5.sum |grep -v ': OK$') ;done
