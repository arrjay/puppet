#!/bin/bash

outdir=$1

# theory of operation: we don't actually know what order we need things in the RRD, so read that, read *all* the sensors, then figure out positioning.

# do nothing if we have no RRD file
if [ ! -f ${outdir}/temps.rrd ] ; then
  exit 2
fi 

# this will hold values and their orders for rrdtool
declare -A inputs

# this will hold the resulting sensor values
declare -A outputs

input_list=$(rrdtool info ${outdir}/temps.rrd | grep '^ds.*type' | sed -e 's/ds\[//' -e 's/\]\.type = .*//')
idx=0
for item in ${input_list} ; do
  inputs[$idx]=$item
  let idx=$idx+1
done

# cheap test to see if anything in here is a disk :)
for dev in "${!inputs[@]}" ; do
  if [ -b "/dev/${inputs[$dev]}" ] ; then
    outputs[$inputs[$dev]]=$(/usr/sbin/smartctl -a /dev/${inputs[$dev]} | grep ^194 | awk '{ print $10 * 10 }')
  fi
done

# collect sensor data now
sensor_out=$(mktemp)
LANG=C sensors -A |grep 'temp.*'|awk '{ print $1,$2 }'|sed -e 's/+//' -e 's/\.//' > $sensor_out
for dev in "${!inputs[@]}" ; do
  if [ -z ${outputs[$inputs[$dev]]} ]; then
    # wasn't a drive, let's find it!
    outputs[$inputs[$dev]]=$(grep ^${inputs[$dev]} $sensor_out | awk -F': ' '{ print $2 }')
  fi
done
rm $sensor_out

# prep rrdtool update
update=""
z=0
while ((z<${#inputs[*]})) ; do
  update="$update:${outputs[$inputs[$z]]}"
  let z++
done
rrdtool update ${outdir}/temps.rrd "N${update}"
