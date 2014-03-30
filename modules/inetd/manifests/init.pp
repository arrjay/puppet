class inetd (
  $wrap_external	= hiera('inetd::wrap_external',true),
  $wrap_internal	= hiera('inetd::wrap_internal',true),
  $maxconn_min		= hiera('inetd::conns_per_min','60'),
  $bind_ip		= hiera('inetd::bind_ip',undef),
) {
  # this class turns on inetd itself and manages 'global' options
  case $::operatingsystem {
    'FreeBSD': {
      $svc = 'inetd'
      $cfg = '/etc/inetd.conf'
    }
  }

  # Create a string or edit a bunch of files?
  case $::operatingsystem {
    'FreeBSD': {
      if $wrap_external {
        $wrap_ext_flags=" -w"
      }
      if $wrap_internal {
        $wrap_int_flags=" -W"
      }
      if $maxconn_min {
        $connflags=" -C $maxconn_min"
      }
      if $bind_ip {
        $bindflags=" -a $bind_ip"
      }
      $inetd_flags="${wrap_ext_flags}${wrap_int_flags}${connflags}${bindflags}"
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
