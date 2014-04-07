class bootparamd (
) {
  $svccmd = hiera('service')

  # get router for bootparamd, else solaris gets damn unhappy.
  $netinfo = hiera_hash('network')

  case $::osfamily {
    'FreeBSD': {
      $config	= '/etc/bootparams'
      $service	= 'bootparams'
    }
  }

  concat{$config:
    owner	=> root,
    group	=> 0,
    mode	=> 0644,
    force	=> true,
    notify	=> Exec["restart bootparamd"],
  }

  # -s to enable syslog, -r to wire down a router
  augeas{"rc.conf: bootparamd flags":
    changes => [ "set /files/etc/rc.conf/bootparamd_flags '\"-s -r $netinfo['router']\"'" ],
    notify  => Exec["restart bootparamd"],
  }

  exec{"restart bootparamd":
    refreshonly	=> true,
    command	=> "$svccmd bootparams restart",
  }

  service{$service: enable => true, ensure => running }
}
