class ftpserver (
  $anonftp	= hiera('ftpserver::anonymous_access',true),
  $ftproot	= hiera('ftpserver::anonroot','/ftproot'),
  $zfs_parent	= hiera('ftpserver::zfs_root',undef),
  $anonshares	= hiera('ftpserver::anonshares',undef),
) {
  if $anonftp {
    user{'ftp':
      uid	=> 21,
      shell	=> '/sbin/nologin',
      home	=> $ftproot,
    }
    file{$ftproot:
      owner	=> root,
      group	=> 0,
    }
  }
  if $zfs_parent {
    zfs{"$zfs_parent/ftproot":
      ensure		=> present,
      devices		=> off,
      exec		=> off,
      mountpoint	=> $tftproot,
      sharenfs		=> off,
    }
  }

  if $anonshares {
    create_resources( share, $anonshares )
  }
}
