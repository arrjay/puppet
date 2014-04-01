class netboot::netbsd_ip2x (
  $version = hiera('netboot::netbsd_ip2x_ver','5.2.2'),
) {
  require netboot
  require netboot::ip2x_common

  $filepath = "$netboot::site_mirror/NetBSD/NetBSD-$version/sgimips/binary/kernel"

  exec{"copy netbsd-INSTALL32_IP2x.gz to tftproot":
    command => "/bin/cp -p $filepath/netbsd-INSTALL32_IP2x.gz $inetd::tftpd::tftproot",
    unless  => "/usr/bin/diff $filepath/netbsd-INSTALL32_IP2x.gz $inetd::tftpd::tftproot/netbsd-INSTALL32_IP2x.gz",
    notify  => Exec['gunzip netbsd-INSTALL32_IP2x.gz'],
  }
  ~>
  exec{"gunzip netbsd-INSTALL32_IP2x.gz":
    command => "/usr/bin/gunzip $inetd::tftpd::tftproot/netbsd-INSTALL32_IP2x.gz",
    refreshonly => true,
  }

  exec{"copy netbsd-INSTALL32_IP2x.ecoff.gz to tftproot":
    command => "/bin/cp -p $filepath/netbsd-INSTALL32_IP2x.ecoff.gz $inetd::tftpd::tftproot",
    unless  => "/usr/bin/diff $filepath/netbsd-INSTALL32_IP2x.ecoff.gz $inetd::tftpd::tftproot/netbsd-INSTALL32_IP2x.ecoff.gz",
    notify  => Exec['gunzip netbsd-INSTALL32_IP2x.ecoff.gz'],
  }
  ~>
  exec{"gunzip netbsd-INSTALL32_IP2x.ecoff.gz":
    command => "/usr/bin/gunzip $inetd::tftpd::tftproot/netbsd-INSTALL32_IP2x.ecoff.gz",
    refreshonly => true,
  }
}
