#!/bin/bash

outdir=$1

# theory of operation: first we get a list of drives, then for each drive we maintain an rrd.
# attempt to use smartctl to get attribute 194 (disk temperature), but if we fail, insert a 0.
# this allows for disks that report temperature...or not

# RRAs to record, if we create an RRD
rras="RRA:AVERAGE:0.5:1:1200 RRA:MIN:0.5:12:2400 RRA:MAX:0.5:12:2400 RRA:AVERAGE:0.5:12:2400"

# get platform - code stolen from dotfiles/bashrc :)
platform=${BASH_VERSINFO[5]}

# get disks
case $platform in
  *freebsd*)
    # handy! a sysctl for exactly this!
    disks=$(sysctl -n kern.disks)
    ;;
  *linux*)
    # find all the scsi class block devices (yes, IDE is this too)
    disks=
    for x in /sys/class/scsi_disk/*/device/block/* ; do
      disk=${x##*/}
      disks="${disk} ${disks}"
    done
    ;;
  *)
    exit 255
    ;;
esac

# we convert tempC to decicelsius so we deal with ints
datasources="DS:reads:COUNTER:600:0:U DS:writes:COUNTER:600:0:U \
DS:hbRead:COUNTER:600:0:U DS:hbWrit:COUNTER:600:0:U DS:qlen:GAUGE:600:0:U \
DS:svctime_mu:GAUGE:600:0:U DS:pctBusy:GAUGE:600:0:100 DS:temp_dC:GAUGE:600:0:2000"

# iostat (or fakery) - modeled from fbsd
# reads:writes:kbRead:kbWrit:qlen:svctime:%busy:tempC
case $platform in
  *freebsd*)
    _iostat() {
      # truncate reads, writes - shift kb to hectobytes(?), milisec to microsec so we record ints
      iostat -Ix $1 | awk 'BEGIN {OFS=":"; ORS=":"} END {print int($2), int($3), $4 * 10, $5 * 10, $6, $7 * 10, $8}'
      # do *this* so we return 0 if we didn't get a temperature
      smartctl -a /dev/${1} | awk '$1 == 194 { f++; print $10 * 10 } END { if (f == 0) print 0 }'
    }
    ;;
  *linux*)
    _iostat() {
      # get device sector size
      read sectorsz < /sys/block/${1}/queue/hw_sector_size
      # read /sys/block/${1}/stat - fight with doublequotes because we need a shell variable inside awk
      cat /sys/block/${1}/stat | awk "BEGIN {OFS=\":\"; ORS=\":\"} { print \$1, \$5, int(\$3 * ${sectorsz} / 100), int(\$7 * ${sectorsz} / 100) }"
      # use iostat to compute service times
      iostat -x ${1} | awk "BEGIN {OFS=\":\"; ORS=\":\"} \$1 == \"${1}\" { print int(\$9), int(\$11 * 10), int(\$12) }"
      smartctl -a /dev/${1} | awk '$1 == 194 { f++; print $10 * 10 } END { if (f == 0) print 0 }'
    }
    ;;
  *)
    exit 128
    ;;
esac

for disk in $disks ; do
  # see if we have a db for this disk, else, create one
  if [ ! -f ${outdir}/${disk}.rrd ] ; then
    rrdtool create ${outdir}/${disk}.rrd -s 300 ${datasources} ${rras}
  fi
  # update the rrd
  update=$(_iostat ${disk})
  rrdtool update ${outdir}/${disk}.rrd "N:${update}"
done
