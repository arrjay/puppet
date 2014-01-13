class mediaserver (
  $packages     = hiera('mediaserver::packages'),
  #$services     = hiera('mediaserver::services'),
  $mtd_config   = hiera('mediaserver::mt_daapd_config'),
  $music_root   = hiera('mediaserver::music_root'),
  $mtd_adminpw  = hiera('mediaserver::mt_daapd_adminpw'),
  $daap_port    = hiera('mediaserver::daap_port'),
  $mtd_webroot  = hiera('mediaserver::mt_daapd_webdir'),
  $mtd_dbroot   = hiera('mediaserver::mt_daapd_dbdir'),
  $mtd_ssc      = hiera('mediaserver::mt_daapd_sscprog'),
  $rescan       = hiera('mediaserver::rescan_interval'),
  $mtd_plugdir  = hiera('mediaserver::mt_daapd_plugdir'),
  $daapd_user   = hiera('mediaserver::mt_daapd_user'),
  $ssc_codecs   = hiera('mediaserver::daapd_ssc_codecs',undef),
  $daapd_exts   = hiera('mediaserver::daapd_extensions','.mp3,.m4a,.m4p'),
  $daapd_dblvl  = hiera('mediaserver::daapd_debuglevel','1'),
  $daapd_scan   = hiera('mediaserver::daapd_scan_without_clients',true),
  $daapd_sctyp  = hiera('mediaserver::daapd_scan_type','2'),
  $daapd_comp   = hiera('mediaserver::daapd_xfr_compression',true),
  $music_upload = hiera('mediaserver::music_upload_dir',undef),
  $music_user   = hiera('mediaserver::music_user'),
  $music_group  = hiera('mediaserver::music_group'),
) {
  # for incoming music share
  include fileserver::samba

  # schedule some processing scripts that flip security perms...
  include crontask
  include sudo

  package{$packages: ensure => installed }

  file{$mtd_config:
    owner   => root,
    group   => 0,
    mode    => 0644,
    content => template('mediaserver/mt-daapd.conf.erb'),
  }

  exec{"/bin/mkdir -p $mtd_dbroot":
    creates => "$mtd_dbroot",
    before  => File[$mtd_dbroot],
  }

  file{$mtd_dbroot:
    owner   => $daapd_user,
  }

  if $music_upload {
    # look up the staging, config dirs now (or fail to compile)
    $music_stage = hiera('mediaserver::music_staging_dir')
    $confdir     = hiera('mediaserver::confdir')
    # create a world writeable directory (hope you backed it with a quota!)
    file{$music_upload:
      ensure => directory,
      mode   => 1777,
      # this user is defined in LDAP....
      owner  => $music_user,
      group  => $music_group,
    }
    file{$music_stage:
      ensure => directory,
      mode   => 0755,
      owner  => $music_user,
      group  => $music_group,
    }
    file{$confdir:
      ensure => directory,
      mode   => 0755,
      owner  => root,
      group  => 0,
    }
    file{"$confdir/music.conf":
      ensure  => present,
      mode    => 0755,
      owner   => root,
      group   => 0,
      content => template("mediaserver/music.conf.erb"),
    }

    fileserver::samba::share{"upload_music": sharepath => $music_upload, read_only => false, writable => yes, comment => "Music uploads", guest_ok => yes, public => yes, create_mask => 0333, dir_mask => 0333, extra => ['hide unreadable = yes']}

    file{"$crontask::dir/music-filer.sh":
      owner  => root,
      group  => 0,
      source => "puppet:///modules/mediaserver/music-filer.sh",
      mode   => 0755,
    }
    file{"$crontask::dir/music-mime-typer.sh":
      owner  => root,
      group  => 0,
      source => "puppet:///modules/mediaserver/music-mime-typer.sh",
      mode   => 0755,
    }
    file{"$crontask::dir/music-flac-handler.sh":
      owner  => root,
      group  => 0,
      source => "puppet:///modules/mediaserver/music-flac-handler.sh",
      mode   => 0755,
    }
  }
}
