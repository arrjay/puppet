class netboot::obsd_ip22 (
  $version = hiera('netboot::obsd_ip22_ver','5.4'),
) {
  require netboot
  class{"tuning::freebsd": portrange_last => '32767'}

  $filepath = "$netboot::site_mirror/OpenBSD/$version/sgi"

  exec{"copy bsd.IP22 to tftproot":
    command => "/bin/cp -p $filepath/bsd.rd.IP22 $inetd::tftpd::tftproot",
    unless  => "/usr/bin/diff $filepath/bsd.rd.IP22 $inetd::tftpd::tftproot/bsd.rd.IP22",
  }

  exec{"copy bootecoff to tftproot":
    command => "/bin/cp -p $filepath/bootecoff $inetd::tftpd::tftproot",
    unless  => "/usr/bin/diff $filepath/bootecoff $inetd::tftpd::tftproot/bootecoff",
  }
}
