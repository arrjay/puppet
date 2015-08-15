class netboot::openbsd::ip22 (
  $version = hiera('netboot::openbsd::ip22:version'),
) {
  include mirror2::openbsd::sgi
  include netboot::ip2x_common

  file{"$::tftp::root/bsd.rd.IP22":
    ensure => present,
    source => "$::mirror2::dest/OpenBSD/$version/sgi/bsd.rd.IP22",
  }

  file{"$::tftp::root/bootecoff":
    ensure => present,
    source => "$::mirror2::dest/OpenBSD/$version/sgi/bootecoff",
  }
}
