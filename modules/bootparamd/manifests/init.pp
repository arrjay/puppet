class bootparamd (
) {
  $svccmd = hiera('service')

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

  exec{"restart bootparamd":
    refreshonly	=> true,
    command	=> "$svccmd bootparams restart",
  }

  service{$service: enable => true, ensure => running }
}
