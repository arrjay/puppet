#!/bin/bash

outdir=$1

rras="RRA:AVERAGE:0.5:1:1200 RRA:MIN:0.5:12:2400 RRA:MAX:0.5:12:2400 RRA:AVERAGE:0.5:12:2400"

datasources="DS:temp0:GAUGE:600:0:212 DS:temp1:GAUGE:600:0:212 DS:temp2:GAUGE:600:0:212 \
DS:fan0:GAUGE:600:0:9999 DS:fan1:GAUGE:600:0:9999 DS:fan2:GAUGE:600:0:9999 \
DS:vcore0:GAUGE:600:0:48 DS:vcore1:GAUGE:600:0:48 \
DS:volt0:GAUGE:600:-48:48 DS:volt1:GAUGE:600:-48:48 DS:volt2:GAUGE:600:-48:48 DS:volt3:GAUGE:600:-48:48 \
DS:volt4:GAUGE:600:-48:48 DS:volt5:GAUGE:600:-48:48"

# if we don't have the RRD file, make it
if [ ! -f ${outdir}/healthd.rrd ] ; then
  rrdtool create ${outdir}/healthd.rrd -s 300 ${datasources} ${rras}
fi 

# collect sensor data now
# riiiight. the first three values are x10 (decicelsius), the next three are x1 (rotation), the remainder are x100 (millivolts)
healthdc_out=$(healthdc|awk 'BEGIN{ORS=":"}{for(i=2;i<=NF;i++){split($i,rec,"|");if(i<=4){print rec[1] * 10};if((i<=7)&&(i>=5)){print rec[1] * 1};if(i>=8){print rec[1] * 100}}}')

# prep rrdtool update
rrdtool update ${outdir}/healthd.rrd "N:${healthdc_out}"
