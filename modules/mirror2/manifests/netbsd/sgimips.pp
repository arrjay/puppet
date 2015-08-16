class mirror2::netbsd::sgimips (
) {
  include mirror2::netbsd

  unless empty($::mirror2::netbsd::versions) {
    $::mirror2::netbsd::versions.each |$ver| {
      mirror2::netbsd::shared{"$ver-mipseb": version => $ver, component => 'mipseb' }

      file { "$::mirror2::dest/NetBSD/NetBSD-$ver/sgimips/":
        ensure => directory,
        mode   => '0755',
      }
      rsync::get{ "$::mirror2::dest/NetBSD/NetBSD-$ver/sgimips/":
        source    => "$::mirror2::rsync_source/NetBSD/NetBSD-$ver/sgimips/",
        purge     => true,
        recursive => true,
      }
    }
  }
}
