class netboot::jumpstart_common (
  $filesystem = hiera('netboot::zfs_fs::jumpstart'),
  $mount = hiera('netboot::mount::jumpstart'),
  $parent = hiera('netboot::zfs_parent::jumpstart'),
) {
  include inetd::tftpd

  # define interfaces here, since many solaris boxes can rarp
  $interfaces = hiera_hash("interface")

  # create zfs fs
  zfs{"$parent/$filesystem":
    ensure => present,
    devices => on,
    mountpoint => $mount,
    sharenfs => 'ro -alldirs -maproot=0:0',
  }

  # slightly different than irix sync - specify a source and dest
  define sync (
    $dest = $title,
    $source,
  ) {
    exec{"rsync4jumpstart: mkdir $dest":
      command => "/bin/mkdir -p $netboot::jumpstart_common::mount/$dest",
      creates => "$netboot::jumpstart_common::mount/$dest",
      notify => Exec["rsync4jumpstart: $dest"],
    }
    exec{"rsync4jumpstart: $dest":
      command => "/usr/local/bin/rsync -rlDx $source/ $netboot::jumpstart_common::mount/$dest/",
      refreshonly => true,
      timeout => 1800,
    }
  }

  # solaris installer wants ICMP netmask replies - go turn it on
  exec {"sysctl: net.inet.icmp.maskrepl":
    command => "/sbin/sysctl net.inet.icmp.maskrepl=1",
    unless => "/sbin/sysctl -n net.inet.icmp.maskrepl|/usr/bin/grep -q 1",
  }
  exec {"add net.inet.icmp.maskrepl to sysctl.conf":
    command => "/bin/echo net.inet.icmp.maskrepl=1 >> /etc/sysctl.conf",
    unless => "/usr/bin/grep -q ^net.inet.icmp.maskrepl /etc/sysctl.conf",
  }
  ->
  # augeas puts spaces in sysctl.conf output *if adding*
    augeas {"sysctl.conf - enable net.inet.icmp.maskrepl":
    changes => [ "set /files/etc/sysctl.conf/net.inet.icmp.maskrepl 1", ],
  }
}
