#!/bin/sh

# hand this script the full path to your mrtg output dir (puppet does this for you)
outdir=$1

for ups in $(upsc -l); do
  if [ ! -f ${outdir}/${ups}.rrd ]; then
    rrdtool create ${outdir}/${ups}.rrd -s 300 'DS:runtime:GAUGE:600:0:U' 'DS:battchrg:GAUGE:600:0:100' 'DS:load:GAUGE:600:0:125' 'DS:battVolt:GAUGE:600:0:480' 'DS:vIn:GAUGE:600:0:1600' 'DS:vOut:GAUGE:600:0:1600' 'RRA:AVERAGE:0.5:1:1200' 'RRA:MIN:0.5:12:2400' 'RRA:MAX:0.5:12:2400' 'RRA:AVERAGE:0.5:12:2400'
  fi
done
