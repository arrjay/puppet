#!/bin/sh

home=${1}

cd ${home}

. ${home}/netboot4irix.conf

rsync -rlDx "${PATCH_MIRROR}"/ "${IRIX_TOPLEVEL}"/patches/
