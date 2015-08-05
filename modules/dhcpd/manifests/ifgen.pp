class dhcpd::ifgen (
  $domain = hiera(resolvconf::domain),
  $nameservers = hiera(resolvconf::nameservers),
) {
  #require dhcpd <- don't actually call this directly from anywhere. ;)
  $lease_default = $::dhcpd::lease_default
  $lease_max     = $::dhcpd::lease_max
  $subnet        = $::dhcpd::subnet
  $netmask       = $::dhcpd::netmask
  $gateway       = $::dhcpd::gateway

  concat {$dhcpd::cfg:
    owner   => root,
    group   => root,  
    notify  => Exec['restart dhcpd'],
  }

  concat::fragment{"dhcpd: start":
    target => $dhcpd::cfg,
    content => template("dhcpd/_header.conf.erb"),
    order => '00',
  }

  concat::fragment{"dhcpd: SUNW vendor options (jumpstart)":
    target => $dhcpd::cfg,
    content => template("dhcpd/sunw.erb"),
    order => '05',
  }

  concat::fragment{"dhcpd:: MacNC vendor options (openfirmware)":
    target => $dhcpd::cfg,
    content => template("dhcpd/macnc.erb"),
    order => '05',
  }

  concat::fragment{"dhcpd: subnet/group routeable":
    target => $dhcpd::cfg,
    content => template("dhcpd/ifgen_start.erb"),
    order => '10',
  }

  concat::fragment{"dhcpd: end routeable/start non-routeable":
    target => $dhcpd::cfg,
    content => template("dhcpd/ifgen_mid.erb"),
    order => '50',
  }

  concat::fragment{"dhcpd: end":
    target => $dhcpd::cfg,
    content => template("dhcpd/ifgen_end.erb"),
    order => '99',
  }

  define dhcp_host(
    $clientname = $title,
    $ip,
    $macaddr = undef,
    $desc = undef,
    $routeable = true,
    $bootfile = undef,
    $vendorspace = undef,
    $extra = undef,
    $bootserver = undef,
    $always_rfc1048 = false,
  ) {
    if $routeable == true {
      concat::fragment{"dhcpd: $clientname":
        target => $dhcpd::cfg,
        order => '20',
        content => template("dhcpd/ifgen.erb"),
      }
    } else {
      concat::fragment{"dhcpd: $clientname":
        target => $dhcpd::cfg,
        order => '70',
        content => template("dhcpd/ifgen.erb"),
      }
    }
  }

  #create_resources('dhcp_host',$_interfaces )
  
}
