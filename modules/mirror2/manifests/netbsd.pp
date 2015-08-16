class mirror2::netbsd (
  $versions = hiera('mirror::netbsd::versions',[]),
) {
  include mirror2

  define mirror2::netbsd::shared(
    $component,
    $version,
  ) {
    file { "$mirror2::dest/NetBSD/NetBSD-$version/shared/$component/":
      ensure  => directory,
      mode    => '0755',
      require => File["$mirror2::dest/NetBSD/NetBSD-$version/shared"],
    }

    rsync::get{ "$::mirror2::dest/NetBSD/NetBSD-$version/shared/$component/":
      source    => "$::mirror2::rsync_source/NetBSD/NetBSD-$version/shared/$component/",
      purge     => true,
      recursive => true,
    }
  }

  unless empty($versions) {
    file { "$mirror2::dest/NetBSD/":
      ensure => directory,
      mode   => '0755',
    }

    $versions.each |$ver| {
      file { ["$mirror2::dest/NetBSD/NetBSD-$ver/","$mirror2::dest/NetBSD/NetBSD-$ver/shared/"]:
        ensure => directory,
        mode   => '0755',
      }

      mirror2::netbsd::shared{"$ver-ALL": version => $ver, component => 'ALL' }

    }
  }
}
