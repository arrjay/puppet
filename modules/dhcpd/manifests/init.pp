class dhcpd {
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

  # calling these for ifgen to work
  $_network = hiera_hash("network")
  $_interfaces = hiera_hash("interface")

  package { $package: ensure => installed }

  exec { "restart dhcpd":
    refreshonly => true,
    command     => "/usr/sbin/service $svc restart",
    subscribe   => File[$cfg],
    onlyif      => "$bin -T -cf $cfg -lf $leases",
  }

  $template = $dhcpd::params['template']

  file {$cfg:
    owner   => root,
    group   => 0,
    content => template("dhcpd/${dhcpd::template}.conf.erb"),
  }

  service { "$svc": enable => true }
}
