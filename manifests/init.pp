class dhcpd {
  case $::operatingsystem {
    'FreeBSD' : {
      $package = 'net/isc-dhcp42-server'
      $cfg     = '/usr/local/etc/dhcpd.conf'
      $svc     = 'isc-dhcpd'
      $bin     = '/usr/local/sbin/dhcpd'
      $leases  = '/var/db/dhcpd/dhcpd.leases'
    }
  }

  $params = hiera_hash("dhcpd")

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
