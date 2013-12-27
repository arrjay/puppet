# class for managing the mirror user's crontasks. assumes you have a mirror user.
class mirror (
  $confdir   = hiera('mirror::confdir'),
  $packages  = hiera('mirror::packages'),
  $mirrordir = hiera('mirror::storedir'),
  $arcdir    = hiera('mirror::archivedir',undef),
) {
  include crontask
  # template abuse pt. 1
  $taskdir = $crontask::dir

  package{$packages: ensure => installed}

  # create mirror dir and parents if needed
  exec {"/bin/mkdir -p $confdir":
    creates => $confdir,
    before  => File[$confdir],
  }

  file {"$confdir":
    ensure => directory,
    owner  => mirror,
    group  => mirror,
    mode   => 0755,
  }

  file {"$mirrordir":
    # whine heartily if you don't have this directory, but don't offer to make it!
    ensure => directory,
    owner  => mirror,
    group  => mirror,
    mode   => 0755,
    noop   => true,
  }

  file{"$confdir/mirror.conf":
    ensure  => present,
    owner   => mirror,
    group   => mirror,
    mode    => 0644,
    content => template("mirror/mirror.conf.erb"),
  }

  file{"$crontask::dir/trimtrees.pl":
    ensure  => present,
    owner   => root,
    group   => 0,
    mode    => 0755,
    source  => "puppet:///modules/mirror/trimtrees.pl",
  }

  #file{"$crontask::dir/mirror-rsync-cygwin.sh":
  #  
  #}

  file{"$crontask::dir/mirror-openbsd.sh":
    ensure  => present,
    owner   => root,
    group   => 0,
    mode    => 0755,
    source  => "puppet:///modules/mirror/mirror-openbsd.sh",
  }

  cron{"mirror-openbsd":
    command  => "$crontask::dir/mirror-tgcware.sh $confdir",
    user     => 'mirror',
    hour     => 8,
    minute   => 3,
    weekday  => 'Fri',
  }

  file{"$crontask::dir/mirror-tgcware.sh":
    ensure  => present,
    owner   => root,
    group   => 0,
    mode    => 0755,
    source  => "puppet:///modules/mirror/mirror-tgcware.sh",
  }

  cron{"mirror-tgcware":
    command  => "$crontask::dir/mirror-tgcware.sh $confdir",
    user     => 'mirror',
    hour     => 15,
    minute   => 10,
    weekday  => 'Tue',
    monthday => '*',
  }

  file{"$crontask::dir/mirror-nekoware.sh":
    ensure  => present,
    owner   => root,
    group   => 0,
    mode    => 0755,
    source  => "puppet:///modules/mirror/mirror-nekoware.sh",
  }

  cron{"mirror-nekoware":
    command  => "$crontask::dir/mirror-nekoware.sh $confdir",
    user     => 'mirror',
    hour     => 11,
    minute   => 7,
    weekday  => 'Mon',
  }

}
