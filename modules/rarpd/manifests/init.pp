class rarpd (
) {
  # needed for the tftp bootfile path
  include tftp

  case $::osfamily {
    'RedHat': {
      # rhel5 was the last version to ship with rarpd ootb
      if versioncmp($::operatingsystemmajrelease, '6') >= 0 {
        include rpmrepo::arrjay
        $packages = ['rarpd']
        $service = "rarpd"
        $sysconf = '/etc/sysconfig/rarpd'
      }
    }
  }

  # own /etc/ethers here in lie of a better idea.
  concat{'ethers':
    path => '/etc/ethers'
  }

  ensure_packages($packages)

  if $sysconf {
    file{"$sysconf":
      content => "OPTIONS='-b ${::tftp::root}'\n",
      notify  => Service[$service],
    }
  }

  service{$service: enable => true, ensure => running}

  define ethertab(
    $clientname = $title,
    $ipaddr,
    $macaddr,
  ) {
    concat::fragment{"ethers: $clientname":
      target  => 'ethers',
      order   => '10',
      content => "$macaddr $ipaddr # $clientname\n",
    }
  }

  # we borrow dhcpd's tooling.
  $hosts = hiera_hostlist()
  $hosts.each |$host| {
    $mac = hiera_hostmac($host)
    if $mac != undef {
      $attrs = hiera_hostdata($host,['macaddr','ipaddr'])
      $ethertab = { $host => $attrs }
      create_resources('ethertab',$ethertab)
    }
  }
}
