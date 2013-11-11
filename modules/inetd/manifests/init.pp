class inetd {
  # this class turns on inetd itself and manages 'global' options
  case $::operatingsystem {
    'FreeBSD': {
      $svc = 'inetd'
      $cfg = '/etc/inetd.conf'
    }
  }

  # Create a string or edit a bunch of files?
  $inetd_cfg = hiera(inetd)
  case $::operatingsystem {
    'FreeBSD': {
      if $inetd_cfg['options']['wrap_external'] {
        $wrap_external=" -w"
      }
      if $inetd_cfg['options']['wrap_internal'] {
        $wrap_internal=" -W"
      }
      if $inetd_cfg['options']['maxconn_min'] {
        $connlim = $inetd_cfg['options']['maxconn_min']
        $connflags=" -C $connlim"
      }
      if $inetd_cfg['options']['bind_ip'] {
        $bind_ip = $inetd_cfg['options']['bind_ip']
        $bindflags=" -a $bind_ip"
      }
      $inetd_flags="${wrap_external}${wrap_internal}${connflags}${bindflags}"
    }
  }
  
  # Execution phase
  case $::operatingsystem {
    'FreeBSD': {
      augeas { "rc.conf: inetd_flags":
        changes => [
          "set /files/etc/rc.conf/inetd_flags '\"$inetd_flags\"'",
        ],
      }
    }
  }

  service { "$svc": enable => true }

  # wire *this* restart to rc.conf changes
  if $inetd_flags {
    exec { "restart inetd":
      refreshonly => true,
      command     => "/usr/sbin/service $svc restart",
      subscribe   => [ Augeas["rc.conf: inetd_flags"] ],
    }
  }
}
