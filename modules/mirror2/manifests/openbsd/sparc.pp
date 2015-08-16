class mirror2::openbsd::sparc(
) {
  include mirror2::openbsd

  unless empty($::mirror2::openbsd::versions) {
    include rsync

    $::mirror2::openbsd::versions.each |$ver| {
      file{ "$::mirror2::dest/OpenBSD/$ver/sparc/":
        require => File["$::mirror2::dest/OpenBSD/$ver/"],
        ensure  => directory,
        mode    => '0755',
      }

      rsync::get{ "$::mirror2::dest/OpenBSD/$ver/sparc/":
        source    => "$::mirror2::rsync_source/OpenBSD/$ver/sparc/",
        purge     => true,
        recursive => true,
      }
    }
  }
}
