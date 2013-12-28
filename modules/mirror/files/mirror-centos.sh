#!/bin/sh

home=${1}

cd ${home}

. ${home}/mirror.conf

for ver in ${CENTOS_VERSIONS} ; do
  for component in ${CENTOS_REPOS} ; do
    for arch in ${CENTOS_ARCHITECTURES} ; do
      mkdir -p ${TOPLEVEL}/centos/${ver}/${component}/${arch}
      rsync -ralp --delete --no-motd ${CENTOS_MIRROR}/${ver}/${component}/${arch}/ ${TOPLEVEL}/centos/${ver}/${component}/${arch}
    done
  done
done

# Handle centos SCL+xen4...differently :/
for repo in ${CENTOS_ADDITIONAL} ; do
  # the only valid arch was x86_64 anyway.
  mkdir -p ${TOPLEVEL}/centos/${repo}/x86_64/
  rsync -ralp --delete --no-motd ${CENTOS_MIRROR}/${repo}/x86_64/ ${TOPLEVEL}/centos/${repo}/x86_64/
done

# Handle EPEL now.
for ver in ${CENTOS_VERSIONS} ; do
  for arch in ${CENTOS_ARCHITECTURES} ; do
    mkdir -p ${TOPLEVEL}/centos/${ver}/epel/${arch}
    rsync -ralp --delete --no-motd ${EPEL_MIRROR}/${ver}/${arch}/ ${TOPLEVEL}/centos/${ver}/epel/${arch}/
  done
done

cd ${TOPLEVEL}/centos

trimtrees.pl . > /dev/null
