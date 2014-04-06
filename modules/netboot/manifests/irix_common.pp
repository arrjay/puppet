class netboot::irix_common (
  $filesystem = hiera('netboot::zfs_fs::irix'),
  $mount = hiera('netboot::mount::irix'),
  $parent = hiera('netboot::zfs_parent::irix'),
  $source = hiera('netboot::rsync::irix'),     # this assumes Our Very Own directory layout. Where to get irix from.
  $userdata = hiera_hash('netboot::user::irix'),
  $kshwrap = hiera('netboot::script::irix::kshwrap','/usr/local/bin/kshwrap'),
  $ksh_path = hiera('netboot::binary::ksh_path'),
  $packages = hiera('netboot::packages::irix_common'),
  $patch_mirror = hiera('netboot::mirror::irix_patches'),
) {
  include inetd::tftpd
  include inetd::rshd

  package{$packages: ensure => installed}

  # create a zfs fs for this
  zfs{"$parent/$filesystem":
    ensure => present,
    devices => on,
    mountpoint => $mount,
    # I'm not sure IRIX needs this, let's comment out until then.
    # sharenfs => 'ro -alldirs',
  }

  # sync job for patches is handled by mirror, but really is part of this - ick.
  # steal the hieradata though.
  $m_confdir = hiera('mirror::confdir')
  $m_uid = hiera('mirror::uid')
  file{"$mount/patches":
    ensure => directory,
    owner => $m_uid,
    group => $m_uid,
  }

  # mount it in tftp-space
  file{"$inetd::tftpd::tftproot/$mount":
    ensure => directory,
  }
  ->
  augeas{"add nullfs mount for tftp chroot - $mount":
    changes => [
      "ins 00 after /files/etc/fstab/*[last()]",
      "set /files/etc/fstab/00/spec $mount",
      "set /files/etc/fstab/00/file $inetd::tftpd::tftproot$mount",
      "set /files/etc/fstab/00/vfstype nullfs",
      "set /files/etc/fstab/00/opt[1] ro",
      "set /files/etc/fstab/00/opt[2] late",
      "set /files/etc/fstab/00/dump 0",
      "set /files/etc/fstab/00/passno 0",
    ],
    onlyif => "match /files/etc/fstab/*[file = '$inetd::tftpd::tftproot$mount'] size < 1",
  }
  ~>
  exec{"mount nullfs in tftp chroot - $mount":
    command => "/sbin/mount $mount",
    unless => "/sbin/mount | /usr/bin/grep -q '^$mount'",
  }

  # sync a subdirectory with rsync
  define sync (
    $component = $title,
  ) {
    exec{"rsync4irix: mkdir $component":
      command => "/bin/mkdir -p $netboot::irix_common::mount/$component",
      creates => "$netboot::irix_common::mount/$component",
      notify => Exec["rsync4irix: $component"],
    }
    exec{"rsync4irix: $component":
      command => "/usr/local/bin/rsync -rlDx $netboot::irix_common::source/$component/ $netboot::irix_common::mount/$component/",
      refreshonly => true,
      timeout => 1800,
    }
  }

  # copy this to a variable or else concat will hate you
  $userhome = $userdata['home']

  file{$kshwrap:
    content => template("netboot/kshwrap.erb"),
    ensure => present,
    owner => root,
    group => 0,
    mode => 0755,
  }
  # add an irix installation user to the system
  user{$userdata['name']:
    ensure => present,
    comment => $userdata['comment'],
    gid => $userdata['gid'],
    uid => $userdata['uid'],
    home => $userdata['home'],
    password => $userdata['password'],
    shell => $kshwrap,
  }
  ->
  # make sure their home exists
  file{$userdata['home']:
    ensure => directory,
    owner => $userdata['name'],
  }
  ->
  # rshd config yay
  concat{"$userhome/.rhosts":
    owner => $userdata['name'],
    group => $userdata['name'],
    mode => 0644,
    force => true,
  }

  # per system irixinst bits
  define grant_rsh (
    $system = $name,
  ) {
    inetd::rshd::hosts_equiv{$system: }
    concat::fragment{"dotrhosts: $system":
      target => "$netboot::irix_common::userhome/.rhosts",
      content => "$system root\n",
    }
  }
}
