class netboot::netbsd_cobalt (
  $source = hiera('netboot::rsync::netbsd_cobalt'),
  $filesystem = hiera('netboot::zfs_fs::netbsd_cobalt'),
  $mount = '/nfsroot',
  $parent = hiera('netboot::zfs_parent::netbsd_cobalt'),
) {
  # takes the existing fs layout from a cobalt restorecd and set it up
  require netboot
  
  # create zfs fs
  zfs{"$parent/$filesystem":
    ensure => present,
    devices => on,
    mountpoint => $mount,
    sharenfs => 'ro -alldirs -maproot=0:0',
  }

  # retrieve cobalt bootfs
  exec{"rsync netbsd/cobalt nfsroot":
    command => "/usr/local/bin/rsync -rlDx \"$source/\" \"$mount\"",
    creates => "$mount/etc/fstab",
  }
  ->
  # fix permissions to match the actual cd again
  file{["$mount/altvar/at/jobs",
        "$mount/altvar/at/spool",
        "$mount/altvar/cron/tabs",
        "$mount/etc/cgd",
        "$mount/etc/openssl/private"]:
    mode => 0700,
    owner => root,
    group => 0,
  }
  ->
  file{["$mount/altvar/crash",
        "$mount/altvar/games/hackdir/save",
        "$mount/altvar/quotas",
        "$mount/usr/games/hide"]:
    mode => 0750,
    owner => root,
    group => 0,
  }
  ->
  file{["$mount/altvar/spool/ftp/hidden"]:
    mode => 0111,
    owner => root,
    group => 0,
  }
  ->
  file{["$mount/altvar/at/at.deny",
        "$mount/altvar/log/authlog",
        "$mount/altvar/log/cron",
        "$mount/altvar/log/maillog",
        "$mount/altvar/log/secure",
        "$mount/altvar/log/xferlog",
        "$mount/etc/hosts.equiv",
        "$mount/etc/master.passwd",
        "$mount/etc/skeykeys",
        "$mount/etc/iscsi/auths",
        "$mount/root/.klogin",
        "$mount/altvar/crash/minfree",
        "$mount/altvar/cron/tabs/root"]:
    mode => 0600,
    owner => root,
    group => 0,
  }
  ->
  file{["$mount/altvar/games/hackdir/record",
        "$mount/altvar/games/phantasia/characs",
        "$mount/altvar/games/phantasia/scoreboard",
        "$mount/altvar/log/lpd-errs"]:
    mode => 0640,
    owner => root,
    group => 0,
  }
  ->
  # replace ip address in fstab with Our Very Own
  augeas{"change nfsroot server in $mount/etc/fstab":
    lens => "Fstab.lns",
    incl => "$mount/etc/fstab",
    changes => [
      "set *[file = \"/\"]/spec \"$::ipaddress:$mount\"",
    ],
  }
}
