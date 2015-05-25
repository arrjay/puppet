class dhcpd (
  $template,
  $lease_default = '86400', # in seconds
  $lease_max     = '86400', # in seconds
  $subnet,
  $netmask,
  $gateway,
) {
  include resolvconf
  case $::osfamily {
    'FreeBSD' : {
      if $::kernelmajversion > 9 {
        $packages = [ 'isc-dhcp42-server' ]
      } else {
        $packages = [ 'net/isc-dhcp42-server' ]
      }
      $cfg        = '/usr/local/etc/dhcpd.conf'
      $svc        = 'isc-dhcpd'
      $bin        = '/usr/local/sbin/dhcpd'
      $leases     = '/var/db/dhcpd/dhcpd.leases'
    }
    'RedHat' : {
      $packages   = [ 'dhcp' ]
      $svc        = 'dhcpd'
      $bin        = 'dhcpd'
      $cfg        = '/etc/dhcp/dhcpd.conf'
      $leases     = '/var/lib/dhcpd/dhcpd.leases'
    }
  }

  $params = hiera_hash("dhcpd::params")
  $dnsdomain    = $resolvconf::domain
  $ns_string    = $resolvconf::ns_string
  # I prefer this to getting a surprise when $::netmask, $::subnet come back in a template
  $dhcp_subnet  = $subnet
  $dhcp_netmask = $netmask

  ensure_packages( $packages )

  exec { "restart dhcpd":
    refreshonly => true,
    command     => "service $svc restart",
    onlyif      => "$bin -T -cf $cfg -lf $leases",
  }

  if $template == ifgen {
    require dhcpd::ifgen
  } else {
    file {$cfg:
      owner   => root,
      group   => 0,
      content => template("dhcpd/${dhcpd::template}.conf.erb"),
      notify  => Exec['restart dhcpd'],
    }
  }

  service { "$svc": enable => true }
}
