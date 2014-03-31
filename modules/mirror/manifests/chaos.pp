# class for managing the mirror user's crontasks. assumes you have a mirror user.
class mirror::chaos (
  $mirrordir	= hiera('mirror::storedir'),
  $mirrorfs	= hiera('mirror::storefs'),
  $mirrorpool	= hiera('mirror::storepool'),
  $confdir	= hiera('mirror::confdir'),
  $uid		= hiera('mirror::uid'),
) {
  package{"net/rsync": ensure => installed}
  include sudo
  include crontask
  # template abuse pt. 1
  $taskdir = $crontask::dir

  zfs {"$mirrorpool/$mirrorfs":
    ensure => present,
    devices => off,
    mountpoint => $mirrordir,
    sharenfs => 'ro -alldirs',
  }

  user{"mirror":
    ensure => present,
    shell => "/sbin/nologin",
    uid   => $uid,
  }

  file{$mirrordir:
    ensure => directory,
    owner  => mirror,
    group  => mirror,
  }

  file{$confdir:
    ensure => directory,
    owner  => mirror,
    group  => mirror,
  }

  file{"$confdir/mirror.conf":
    ensure => present,
    owner => mirror,
    group => mirror,
    mode => 0644,
    content => template("mirror/mirror.chaos.conf.erb"),
  }

  file{"$crontask::dir/mirror-openbsd.sh":
    ensure => present,
    owner => root,
    group => 0,
    mode => 0755,
    source => "puppet:///modules/mirror/mirror-openbsd.sh",
  }

  cron{"mirror-openbsd":
    command => "$crontask::dir/mirror-openbsd.sh $confdir",
    user    => mirror,
    hour    => 20,
    minute  => 0,
    weekday => 'Fri',
  }
}
