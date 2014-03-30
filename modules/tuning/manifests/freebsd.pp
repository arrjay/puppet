class tuning::freebsd(
  $portrange_last = hiera('tuning::portrange_last',undef)
) {
  if $portrange_last {
    exec {"sysctl - ip portrange last $portrange_last":
      command => "/sbin/sysctl net.inet.ip.portrange.last=$portrange_last",
      unless  => "/sbin/sysctl -n net.inet.ip.portrange.last|/usr/bin/grep -q ^$portrange_last",
    }
    exec {"add ip portrange last to sysctl.conf":
      command => "/bin/echo net.inet.ip.portrange.last=$portrange_last >> /etc/sysctl.conf",
      unless  => "/usr/bin/grep -q ^net.inet.ip.portrange.last /etc/sysctl.conf",
    }
    ->
    # augeas puts spaces in sysctl.conf output *if adding*
    augeas {"sysctl.conf - ip portrange last $portrange_last":
      changes => [ "set /files/etc/sysctl.conf/net.inet.ip.portrange.last $portrange_last", ],
    }
  }
}
