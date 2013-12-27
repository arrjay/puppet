#!/bin/sh

home=${1}

cd ${home}

. ${home}/mirror.conf

for branch in ${TGCWARE_DISTS} ; do
  mkdir -p ${TOPLEVEL}/tgcware/${branch}
  cd ${TOPLEVEL}/tgcware/${branch}
  for url in $(lynx -dump -listonly http://${TGCWARE_SITE}/${branch}/ | grep tardist | sed 's/^ .* //') ; do
    tardist=$(echo $url|sed s@.*/@@)
    if [ ! -f ${tardist} ] ; then
      # sleep from 1 to 3 seconds
      # NOTE: FreeBSDism
      sleep $(jot -r 1 1 3)
      wget -q $url
      # check if it worked with tar, toss the listing not the error
      tar tf ${tardist} > /dev/null
      if [ $? -ne 0 ] ; then
        echo "removed ${tardist}"
        rm ${tardist}
      fi
    fi
  done
done
