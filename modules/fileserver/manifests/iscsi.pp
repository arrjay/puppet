class fileserver::iscsi {
  include fileserver

  case $::osfamily {
    'RedHat': {
      if $::operatingsystemmajrelease > 6 {
        $packages = ['targetcli']
      } else {
        # um.
      }
    }
  }

  if $packages {
    package{$packages: ensure => installed}
  }
}
