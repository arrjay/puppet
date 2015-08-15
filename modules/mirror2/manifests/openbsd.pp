class mirror2::openbsd (
  $versions = hiera('mirror::openbsd::versions',[]),
) {
  include mirror2

  unless empty($versions) {
    file { "$mirror2::dest/OpenBSD/":
      ensure => directory,
      mode   => '0755',
    }

    $versions.each |$ver| {
      file { "$mirror2::dest/OpenBSD/$ver/":
        ensure => directory,
        mode   => '0755',
      }
    }
  }
}
