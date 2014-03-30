class rarpd (
) {
  include inetd::tftpd

  $_interfaces = hiera_hash('interface')

  case $::osfamily {
    'FreeBSD': {
      $ethers	= "/etc/ethers"
      $flags	= "-a -t $inetd::tftpd::tftproot"
      $service	= "rarpd"
    }
  }

  file{$ethers:
    owner	=> root,
    group	=> 0,
    content	=> template("rarpd/ethers.erb"),
  }

  case $::osfamily {
    'FreeBSD': {
      augeas{"rc.conf flags - rarpd":
        changes => [ "set /files/etc/rc.conf/rarpd_flags '\"$flags\"'", ],
      }
    }
  }

  service{$service: enable => true, ensure => running}
}
