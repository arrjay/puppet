#!/bin/sh

home=${1}

cd ${home}

. ${home}/mirror.conf

# sync openbsd base distros
for ver in ${OBSD_VERSIONS} ; do
 for arch in ${OBSD_ARCHITECTURES} ; do
   mkdir -p ${TOPLEVEL}/OpenBSD/${ver}/${arch}
   rsync -ralp --delete --no-motd ${OBSD_MIRROR}/${ver}/${arch}/ ${TOPLEVEL}/OpenBSD/${ver}/${arch}/
 done
done

# get openbsd packages - handy if we do an airgapped install
for tree in ${OBSD_PACKAGETREES} ; do
  mkdir -p ${TOPLEVEL}/OpenBSD/${tree}
  rsync -ralp --delete --no-motd ${OBSD_MIRROR}/${tree}/ ${TOPLEVEL}/OpenBSD/${tree}/
done
