class netboot::openbsd::ip22 (
  $version = hiera('netboot::openbsd::ip22::version'),
) {
  include mirror2::openbsd::sgi
  include netboot::ip2x_common

  ensure_resource('netboot::openbsd::tftpdir',$version)

  file{"$::tftp::root/obsd-$version/sgi":
    ensure => directory,
    mode   => '0755',
  }

  file{"$::tftp::root/obsd-$version/sgi/bsd.rd.IP22":
    ensure => present,
    source => "$::mirror2::dest/OpenBSD/$version/sgi/bsd.rd.IP22",
  }

  file{"$::tftp::root/obsd-$version/sgi/bootecoff":
    ensure => present,
    source => "$::mirror2::dest/OpenBSD/$version/sgi/bootecoff",
  }
}
