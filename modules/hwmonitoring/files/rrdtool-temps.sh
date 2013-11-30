#!/bin/bash

outdir=$1

# RRAs stored in the RRD. IF YOU CHANGE THIS, IT IS UP TO YOU TO DELETE THE RRD!
rras="RRA:AVERAGE:0.5:1:1200 RRA:MIN:0.5:12:2400 RRA:MAX:0.5:12:2400 RRA:AVERAGE:0.5:12:2400"

# figure out what sensors we are collecting
sensor_out=$(sensors -A|grep ':'|awk -F':' '{ print $1 }')

# turn into hash
declare -A sensors
for sensor in ${sensor_out} ; do
  sensors[$sensor]=exists
done

# list of HBA drivers known-to-work with smartctl
declare -A smartctl
smartctl[ahci]=ok
smartctl[ata_generic]=ok
smartctl[pata_atiixp]=ok

# this will become a list of block devices to monitor
declare -A disks

# find your hard drives! yeech.
for host in /sys/class/scsi_host/* ; do
  read proc_name < $host/proc_name
  if [ "${smartctl[$proc_name]}" == "ok" ]; then
    for dev in ${host}/device/target*/*/block/* ; do
      if [ -f $dev/removable ] ; then
        read removable < $dev/removable
        if [ "${removable}" -eq 0 ]; then
          dev_name=$(basename $dev)
          disks[${dev_name}]=ok
        fi
      fi
    done
  fi
done

function mkrrd {
  datasources=""
  for disk in "${!disks[@]}" ; do
   datasources="$datasources DS:${disk}:GAUGE:600:0:2000"
  done
  for sensor in "${!sensors[@]}" ; do
    if [ "${sensor:0:4}" == "temp" ] ; then
      datasources="$datasources DS:${sensor}:GAUGE:600:0:2000"
    fi
  done
  rrdtool create ${outdir}/temps.rrd -s 300 ${datasources} ${rras}
}

if [ -f  ${outdir}/temps.rrd ] ; then
  # do we need to re-create the rrd?
  current_list=$(rrdtool info ${outdir}/temps.rrd | grep '^ds.*type' | sed -e 's/ds\[//' -e 's/\]\.type = .*//')
  all_ok=yes
  declare -A rrdsources
  for item in ${current_list} ; do
    rrdsources[$item]=exists
  done
  for disk in "${!disks[@]}" ; do
    if [ "${rrdsources[$disk]}" != "exists" ]; then
      all_ok=NO
    fi
  done
  for sensor in "${!sensors[@]}" ; do
    if [ "${sensor:0:4}" == "temp" ] ; then
      if [ "${rrdsources[$sensor]}" != "exists" ]; then
        all_ok=NO
      fi
    fi
  done
  if [ $all_ok != yes ] ; then
    mv -f ${outdir}/temps.rrd ${outdir}/temps.rrd.old
    mkrrd
  fi
else
  # didn't have an rrd, make one
  mkrrd
fi
