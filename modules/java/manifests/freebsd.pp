class java::freebsd {
  exec{"mount: /dev/fd":
    refreshonly => true,
    command     => "/sbin/mount /dev/fd",
  }
  exec{"mount: /proc":
    refreshonly => true,
    command     => "/sbin/mount /proc",
  }
  augeas{"/etc/fstab: add fdescfs":
    changes => [
      "set /files/etc/fstab/01/spec fdesc",
      "set /files/etc/fstab/01/file /dev/fd",
      "set /files/etc/fstab/01/vfstype fdescfs",
      "set /files/etc/fstab/01/opt rw",
      "set /files/etc/fstab/01/dump 0",
      "set /files/etc/fstab/01/passno 0",
    ],
    onlyif  => "match /files/etc/fstab/*[file='/dev/fd'] size == 0",
    notify  => Exec["mount: /dev/fd"],
  }
  augeas{"/etc/fstab: add proc":
    changes => [
      "set /files/etc/fstab/01/spec proc",
      "set /files/etc/fstab/01/file /proc",
      "set /files/etc/fstab/01/vfstype procfs",
      "set /files/etc/fstab/01/opt rw",
      "set /files/etc/fstab/01/dump 0",
      "set /files/etc/fstab/01/passno 0",
    ],
    onlyif  => "match /files/etc/fstab/*[file='/proc'] size == 0",
    notify  => Exec["mount: /proc"],
  }
}
