class mirror2::openbsd::sgi (
) {
  include mirror2::openbsd

  unless empty($::mirror2::openbsd::versions) {
    include rsync

    $::mirror2::openbsd::versions.each |$ver| {
      # create destination directory
      file{ "$::mirror2::dest/OpenBSD/$ver/sgi/":
        require => File["$::mirror2::dest/OpenBSD/$ver/"],
        ensure  => directory,
        mode    => '0755',
      }

      rsync::get{ "$::mirror2::dest/OpenBSD/$ver/sgi/":
        source    => "$::mirror2::rsync_source/OpenBSD/$ver/sgi/",
        purge     => true,
        recursive => true,
      }
    }
  }
}
