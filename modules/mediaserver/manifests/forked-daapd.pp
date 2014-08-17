class mediaserver::forked-daapd (
) {
  # per-os variables

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
}
