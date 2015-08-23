class netboot::openbsd::sparc (
  $version = hiera('netboot::openbsd::sparc::version'),
) {
  include mirror2::openbsd::sparc
  include netboot::sparc_common
  include bootparams

  ensure_resource('netboot::openbsd::tftpdir',$version)

  file{"$::tftp::root/obsd-$version/sparc":
    ensure => directory,
    mode   => '0755',
  }

  file{"$::tftp::root/obsd-$version/sparc/boot.net":
    ensure => present,
    source => "$::mirror2::dest/OpenBSD/$version/sparc/boot.net",
  }

}
