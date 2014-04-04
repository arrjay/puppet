class dhcpd (
  $template = hiera(dhcpd::template),
) {
  case $::osfamily {
    'FreeBSD' : {
      if $::kernelmajversion > 9 {
        $package = 'isc-dhcp42-server'
      } else {
        $package = 'net/isc-dhcp42-server'
      }
      $cfg     = '/usr/local/etc/dhcpd.conf'
      $svc     = 'isc-dhcpd'
      $bin     = '/usr/local/sbin/dhcpd'
      $leases  = '/var/db/dhcpd/dhcpd.leases'
    }
  }

  $params = hiera_hash("dhcpd")
  $dnsdomain = hiera("dnsdomain")

  package { $package: ensure => installed }

  exec { "restart dhcpd":
    refreshonly => true,
    command     => "/usr/sbin/service $svc restart",
    onlyif      => "$bin -T -cf $cfg -lf $leases",
  }

  if $template == ifgen {
    require dhcpd::ifgen
  } else {
    file {$cfg:
      owner   => root,
      group   => 0,
      content => template("dhcpd/${dhcpd::template}.conf.erb"),
      notify  => ['restart dhcpd'],
    }
  }

  service { "$svc": enable => true }
}
