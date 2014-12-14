#!/bin/sh
REAL_HOME_ROOT=/private/home
SHELLS=/etc/shells

# get selinux status
# you may want to 'semanage permissive -a automount_t' for this to actually work under selinux...
if [ -f /usr/sbin/selinuxenabled ] ; then
  selinuxenabled 2>&1
  if [ $? -ne 0 ] ; then
    CP_FLAGS=""
  else
    # provide context
    CP_FLAGS="--context=unconfined_u:object_r:user_home_t:s0"
  fi
fi


case "$1" in
  *)
    # most common case - parent exists.
    if [ -d ${REAL_HOME_ROOT}/${1} ]; then
      echo "-fstype=bind :${REAL_HOME_ROOT}/${1}"
      exit 0
    fi
    # see if this is a valid user (returned getent)
    getent_out=$(getent passwd ${1})
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
        exit 0
        ;;
      *)
        ;;
    esac
    # check homedir for /home
    pwent_home=$(echo $getent_out|awk -F: '{print $6}')
    echo $pwent_home | grep -q '^/home/'
    if [ $? -ne 0 ] ; then
      exit 0
    fi
    # if we got to here, user validation is...reasonable. make the directory, pop /etc/skel in
    set -e
    pwent_uidgid=$(echo $getent_out|awk -F: 'OFS=":" {print $3,$4}')
    mkdir -p "${REAL_HOME_ROOT}"
    mkdir -p $CP_FLAGS "${REAL_HOME_ROOT}/${1}"
    # http://superuser.com/questions/61611/how-to-copy-with-cp-to-include-hidden-files-and-hidden-directories-and-their-con
    cp -R $CP_FLAGS /etc/skel/. "${REAL_HOME_ROOT}/${1}"
    chmod 0700 "${REAL_HOME_ROOT}/${1}"
    chown -R ${pwent_uidgid} ${REAL_HOME_ROOT}/${1}
    echo "-fstype=bind :${REAL_HOME_ROOT}/${1}"
  ;;
esac
