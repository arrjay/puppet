#!/bin/sh

home=${1}

cd ${home}

. ${home}/mirror.conf

# sync netbsd base distros
for ver in ${NETBSD_VERSIONS} ; do
 for arch in ${NETBSD_ARCHITECTURES} ; do
   mkdir -p ${TOPLEVEL}/NetBSD/NetBSD-${ver}/${arch}
   rsync -ralp --delete --no-motd ${NETBSD_MIRROR}/NetBSD-${ver}/${arch}/ ${TOPLEVEL}/NetBSD/NetBSD-${ver}/${arch}/
 done
done

# get openbsd packages - handy if we do an airgapped install
for tree in ${NETBSD_PACKAGETREES} ; do
    mkdir -p ${TOPLEVEL}/pkgsrc/packages/NetBSD/${tree}
    rsync -ralp --no-motd ${PKGSRC_MIRROR}/packages/NetBSD/${tree}/ ${ARCHIVEDIR}/pkgsrc/packages/NetBSD/${tree}/
done
