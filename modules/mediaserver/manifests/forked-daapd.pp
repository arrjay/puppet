class mediaserver::forked-daapd (
) {
  # per-os variables
  case $::osfamily {
    'RedHat' : {
      $daapd_config = '/etc/forked-daapd.conf'
    }
  }

  # per-os initialization
  case $::osfamily {
    'RedHat' : {
      # suck in the repos so the package install has a hope of working
      include rpmrepo::epel
      include rpmrepo::rpmfusion-free-updates
      include rpmrepo::arrjay

      package {'forked-daapd': ensure => 'installed'}
    }
  }

  # common initialization
  include avahi

  file{$daapd_config:
    owner => 'root',
    group => 0,
    mode => '0644',
    content => template('mediaserver/forked-daapd.conf.erb'),
  }
}
