#!/bin/sh

outdir=$1

for ups in $(upsc -l); do
  if [ -f ${outdir}/${ups}.rrd ]; then
    runtime=$(upsc $ups battery.runtime)
    battchrg=$(upsc $ups battery.charge)
    load=$(upsc $ups ups.load 2> /dev/null)
    # really? FINE. report the UPS as fully loaded.
    if [ $? -ne 0 ]; then
      load=100
    fi
    battVolt=$(upsc $ups battery.voltage | sed -s 's/\.//')
    # one of the newer APC UPS did not report this...?
    vIn=$(upsc $ups input.voltage 2> /dev/null)
    if [ $? -ne 0 ]; then
      vIn=0
    else
      vIn=$(echo $vIn|sed -e 's/\.//')
    fi
    # usbhid-ups, at least, doesn't seem to support this
    vOut=$(upsc $ups output.voltage 2> /dev/null)
    if [ $? -ne 0 ]; then
      vOut=0
    else
      vOut=$(echo $vOut|sed -e 's/\.//')
    fi
    rrdtool update ${outdir}/${ups}.rrd N:${runtime}:${battchrg}:${load}:${battVolt}:${vIn}:${vOut}
  fi
done
