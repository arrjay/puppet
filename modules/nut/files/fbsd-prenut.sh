#!/bin/sh
# PROVIDE: prenut
# BEFORE: nut

# rely on nut being enabled (or not)
nut_enable=${nut_enable-"NO"}
nut_prefix=${nut_prefix-"/usr/local"}

. /etc/rc.subr
name="prenut"
rcvar=nut_enable

load_rc_config $name

command="${nut_prefix}/libexec/nut/grab_hidups.sh"

run_rc_command "$1"
