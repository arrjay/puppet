define netboot::openbsd::tftpdir (
  $version = $title,
) {
  include tftp
  file{"${::tftp::root}/obsd-${version}":
    ensure => directory,
    mode   => '0755',
  }
}
