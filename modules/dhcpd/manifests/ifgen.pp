class dhcpd::ifgen {
  # because puppet is in love with write-only variables, we invoke concat to do this now.

  # calling these for ifgen to work
  $_network = hiera_hash("network")
  $_interfaces = hiera_hash("interface")

  concat {$dhcpd::cfg:
    owner   => root,
    group   => 0,  
    notify  => Exec['restart dhcpd'],
  }

  concat::fragment{"dhcpd: start":
    target => $dhcpd::cfg,
    content => template("dhcpd/_header.conf.erb"),
    order => 00,
  }

  concat::fragment{"dhcpd: subnet/group routeable":
    target => $dhcpd::cfg,
    content => template("dhcpd/ifgen_start.erb"),
    order => 01,
  }

  concat::fragment{"dhcpd: end routeable/start non-routeable":
    target => $dhcpd::cfg,
    content => template("dhcpd/ifgen_mid.erb"),
    order => 50,
  }

  concat::fragment{"dhcpd: end":
    target => $dhcpd::cfg,
    content => template("dhcpd/ifgen_end.erb"),
    order => 99,
  }

  define dhcp_host(
    $clientname = $title,
    $ip,
    $macaddr = undef,
    $desc = undef,
    $routeable = true,
    $bootfile = undef,
  ) {
    if $routeable == true {
      concat::fragment{"dhcpd: $clientname":
        target => $dhcpd::cfg,
        order => 20,
        content => template("dhcpd/ifgen.erb"),
      }
    } else {
      concat::fragment{"dhcpd: $clientname":
        target => $dhcpd::cfg,
        order => 70,
        content => template("dhcpd/ifgen.erb"),
      }
    }
  }

  create_resources('dhcp_host',$_interfaces )
  

  # this lets you override a default dhcp host.
  # this only works if you defined the host *previously*
  # (and it will fail with the *weirdest* error, see below.)
  # Could not retrieve catalog from remote server: Error 400 on SERVER: $dhcpd::ifgen::_interfaces[$clientname] is :undef, not a hash or array at /etc/puppet
  #class dhcpd::hostparams inherits dhcpd::ifgen (
  #  $clientname = $title,
  #  $bootfile = $dhcpd::ifgen::_interfaces[$clientname]['bootfile'],
  #) {
  #  ip => $dhcpd::ifgen::_interfaces[$clientname]['ip'],
  #  macaddr => $dhcpd::ifgen::_interfaces[$clientname]['macaddr'],
  #  desc => $dhcpd::ifgen::_interfaces[$clientname]['desc'],
  #  routeable => $dhcpd::ifgen::_interfaces[$clientname]['routeable'],
  #  bootfile => $bootfile,
  #}

}
