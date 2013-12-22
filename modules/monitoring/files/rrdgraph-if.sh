#!/bin/bash

outdir=$1

# theory of operation: first we get a list of interfaces, then for each interface, we maintain an rrd.

# RRAs to record, if we create an RRD
rras="RRA:AVERAGE:0.5:1:1200 RRA:MIN:0.5:12:2400 RRA:MAX:0.5:12:2400 RRA:AVERAGE:0.5:12:2400"

# get platform - code stolen from dotfiles/bashrc :)
platform=${BASH_VERSINFO[5]}

# get disks
case $platform in
  *freebsd*)
    iflist=$(ifconfig -l)
    ;;
  *linux*)
    # linux, filter out virtual interfaces (from VMM hosts)
    # first, everything that's a real device
    iflist=
    for x in /sys/class/net/*/device ; do
      devtype=""
      if [ -f ${x}/devtype ]; then
        read devtype < ${x}/devtype
      fi
      if [ "$devtype" != "vif" ]; then
        interface=${x#/sys/class/net/}
        interface=${interface%/device}
        iflist="${interface} ${iflist}"
      fi
    done
    # see if brctl is installed - get bridges
    which brctl &> /dev/null
    if [ $? -eq 0 ]; then
      # use awk here to filter out bridges by checking a bridge id
      iflist="$(brctl show | awk 'BEGIN {ORS=" "} $2 ~ 8 { print $1 }')${iflist}"
    fi
    # hardcode lo back in...
    iflist="lo ${iflist}"
    ;;
  *)
    exit 255
    ;;
esac

# modeled from FreeBSD's netstat reporting
# ipkts:ierrs:idrop:ibytes:opkts:oerrs:obytes:coll
datasources="DS:ipkts:COUNTER:600:0:U DS:ierrs:COUNTER:600:0:U \
DS:idrop:COUNTER:600:0:U DS:ibytes:COUNTER:600:0:U \
DS:opkts:COUNTER:600:0:U DS:oerrs:COUNTER:600:0:U DS:obytes:COUNTER:600:0:U \
DS:coll:COUNTER:600:0:U"

# netstat (or fakery)
case $platform in
  *freebsd*)
    _ifstat() {
      netstat -ibnWI ${1} -f link | awk "BEGIN {OFS=\":\"} \$1 ~ \"${1}\" { print \$5, \$6, \$7, \$8, \$9, \$10, \$11, \$12 }"
    }
    ;;
  *linux*)
    _ifstat() {
      bytes=$(ifconfig $1 | sed 's/^[ ]*//'|awk -F: '$1 == "RX bytes" { print $2, $3 }'|awk 'BEGIN{OFS=":"} { print $1, $6 }')
      netstat -inN | awk "BEGIN {OFS=\":\"} \$1 == \"${1}\" { i++ ; print \$4, \$5, \$6, ${bytes%:*}, \$8, \$9, ${bytes#*:}, \$11 + \$7 } END { if ( i == 0 ) print 0, 0, 0, 0, 0, 0, 0, 0 }"
    }
    ;;
  *)
    exit 128
    ;;
esac

for interface in $iflist ; do
  # see if we have a db for this disk, else, create one
  if [ ! -f ${outdir}/${interface}.rrd ] ; then
    rrdtool create ${outdir}/${interface}.rrd -s 300 ${datasources} ${rras}
  fi
  # update the rrd
  update=$(_ifstat ${interface})
  rrdtool update ${outdir}/${interface}.rrd "N:${update}"
done
