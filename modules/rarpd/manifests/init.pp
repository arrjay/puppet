class rarpd (
) {
  case $::osfamily {
    'RedHat': {
      # rhel5 was the last version to ship with rarpd ootb
      if versioncmp($::operatingsystemmajrelease, '6') >= 0 {
        include rpmrepo::arrjay
        $packages = ['rarpd']
        $service = "rarpd"
      }
    }
  }

  # own /etc/ethers here in lie of a better idea.
  concat{'ethers':
    path => '/etc/ethers'
  }

  ensure_packages($packages)

  service{$service: enable => true, ensure => running}
}
