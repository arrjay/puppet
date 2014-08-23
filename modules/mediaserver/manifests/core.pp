class mediaserver::core (
  $packages     = hiera('mediaserver::packages'),
  $music_upload = hiera('mediaserver::music_upload_dir',undef),
  $music_user   = hiera('mediaserver::music_user'),
  $music_group  = hiera('mediaserver::music_group'),
  $music_root   = hiera('mediaserver::music_root'),
) {
  # schedule some processing scripts that flip security perms...
  include crontask
  include sudo

  package{$packages: ensure => installed }

  # LAME on FreeBSD is a restricted port :x
  case $::operatingsystem {
    'FreeBSD': {
      require freebsd::portupgrade
      #package{[
      #  "converters/libiconv",
      #  "devel/gmake",
      #  "devel/libtool",
      #]: ensure => installed } ~> 
      package {'audio/lame': ensure => installed, provider => 'portupgrade' }
    }
  }

  if $music_upload {
    # look up the staging, config dirs now (or fail to compile)
    $music_stage = hiera('mediaserver::music_staging_dir')
    $confdir     = hiera('mediaserver::confdir')
    $music_meta  = hiera('mediaserver::music_meta_dir')
    # for incoming music share
    include fileserver::samba

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
    file{$music_meta:
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
    file{"$confdir/run":
      ensure => directory,
      mode   => 0700,
      owner  => $music_user,
      group  => $music_group,
    }
    file{"$confdir/music.conf":
      ensure  => present,
      mode    => 0755,
      owner   => root,
      group   => 0,
      content => template("mediaserver/music.conf.erb"),
    }
    vcsrepo{"$confdir/misc-scripts":
      ensure   => present,
      provider => git,
      source   => "https://github.com/arrjay/misc-scripts.git",
    }
    file{"$confdir/bin":
      ensure   => directory,
      owner    => root,
      group    => 0,
    }
    file{"$confdir/bin/flac2mp3":
      ensure   => link,
      target   => "../misc-scripts/noarch/flac2mp3",
    }
    file{"$confdir/bin/mp3getcomp":
      ensure   => link,
      target   => "../misc-scripts/noarch/mp3getcomp",
    }

    fileserver::samba::share{"upload_music": sharepath => $music_upload, read_only => false, writable => yes, comment => "Music uploads", guest_ok => yes, public => yes, create_mask => 0333, dir_mask => 0333, extra => ['hide unreadable = yes']}
    fileserver::samba::share{"music-staging": sharepath => $music_stage, read_only => true, writable => no, comment => "Music staging area", guest_ok => yes, public => yes }

    file{"$crontask::dir/music-filer.sh":
      owner  => root,
      group  => 0,
      source => "puppet:///modules/mediaserver/music-filer.sh",
      mode   => 0755,
    }
    file{"$confdir/bin/music-mime-typer.sh":
      owner  => root,
      group  => 0,
      source => "puppet:///modules/mediaserver/music-mime-typer.sh",
      mode   => 0755,
    }
    file{"$confdir/bin/music-flac-handler.sh":
      owner  => root,
      group  => 0,
      source => "puppet:///modules/mediaserver/music-flac-handler.sh",
      mode   => 0755,
    }
    file{"$confdir/bin/music-m4a-handler.sh":
      owner  => root,
      group  => 0,
      source => "puppet:///modules/mediaserver/music-m4a-handler.sh",
      mode   => 0755,
    }
    file{"$confdir/bin/music-mp3-handler.sh":
      owner  => root,
      group  => 0,
      source => "puppet:///modules/mediaserver/music-mp3-handler.sh",
      mode   => 0755,
    }
  }
}
