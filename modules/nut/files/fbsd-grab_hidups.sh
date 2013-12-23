#!/bin/sh

for dev in $(usbconfig |grep 'American Power Conversion'|awk -F: '{print $1}') ; do
  chown uucp /dev/${dev}
done
