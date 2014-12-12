#!/bin/sh
ZFS_PARENT_DIR=/datapool/home
ZFS_PARENT_FS=datapool/home
SHELLS=/etc/shells
ZFS=/usr/sbin/zfs
CHOWN=/usr/sbin/chown

# this map creates local zfs filesystems and returns them as homedir candidates.
case "$1" in
  * )
    # most common case - parent exists.
    if [ -d ${ZFS_PARENT_DIR}/${1} ]; then
      echo "-fstype=bind :${ZFS_PARENT_DIR}/${1}"
      exit 0
    fi
    # see if this is a valid user with a shell specified
    getent_out=$(getent passwd $1)
    # if getent failed, return immediately
    if [ $? -ne 0 ] ; then
      exit 0
    fi
    # check shell
    pwent_baseshell=$(basename $(echo $getent_out|awk -F: '{print $7}'))
    grep -q $pwent_baseshell ${SHELLS}
    if [ $? -ne 0 ] ; then
      exit 0
    fi
    case $pwent_baseshell in
    *nologin*)
      # well...go away
      exit 0
      ;;
    *)
      ;;
    esac
    # check homedir for /home/
    pwent_home=$(echo $getent_out|awk -F: '{print $6}')
    echo $pwent_home | grep -q '^/home/'
    if [ $? -ne 0 ] ; then
      exit 0
    fi
    # if we got to here, create the ZFS fs, then return a link
    # blow up if anything else go screwy now :)
    set -e
    pwent_uidgid=$(echo $getent_out|awk -F: 'OFS=":" {print $3,$4}')
    ${ZFS} create ${ZFS_PARENT_FS}/${1}
    cp -R /etc/skel/ ${ZFS_PARENT_DIR}/${1}/
    ${CHOWN} -R ${pwent_uidgid} ${ZFS_PARENT_DIR}/${1}
    chmod 0700 ${ZFS_PARENT_DIR}/${1}
    # return the fs to autofs!
    echo "-fstype=bind :${ZFS_PARENT_DIR}/${1}"
    ;;
esac
