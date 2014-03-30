define ftpserver::share(
  $share = $title,
  $dest,
) {
  file{"$ftpserver::ftproot/$share":
    ensure => directory
  }
  augeas{"add nullfs mount for ftp chroot - $share":
    changes => [
      "ins 00 after /files/etc/fstab/*[last()]",
      "set /files/etc/fstab/00/spec $dest",
      "set /files/etc/fstab/00/file $ftpserver::ftproot/$share",
      "set /files/etc/fstab/00/vfstype nullfs",
      "set /files/etc/fstab/00/opt[1] ro",
      "set /files/etc/fstab/00/opt[2] late",
      "set /files/etc/fstab/00/dump 0",
      "set /files/etc/fstab/00/passno 0",
    ],
    onlyif => "match /files/etc/fstab/*[file = '$ftpserver::ftproot/$share'] size < 1",
  }
  ~>
  exec{"mount nullfs in ftp chroot - $share":
    command => "/sbin/mount $ftpserver::ftproot/$share",
    unless  => "/sbin/mount | /usr/bin/grep -q '$ftpserver::ftproot/$share'",
  }
}
