class automount (
  $services = hiera('automount::services',undef),
  $packages = hiera('automount::packages',undef),
  $maptype  = hiera('automount::maptype',undef),
  $mapdir   = hiera('automount::mapdir','/etc'),
  $homemap  = hiera('automount::auto_home','amd_nethome'),
  $hmapperm = hiera('automount::perms_auto_home','0644'),
  $maphome  = hiera('automount::map_home',false),
  $svccmd   = hiera('service',undef),
) {
  if $services {
    service { $services: enable => true, ensure => running }
  }
  if $packages {
    package { $packages: ensure => installed }
  }
  if $maptype == 'sun' {
  }
  if $maptype == 'am-utils' {
    exec {"restart amd":
      refreshonly => true,
      command     => "$svccmd amd restart",
    }
    exec {"reload amd":
      refreshonly => true,
      command     => "$svccmd amd reload",
    }
    file {"$mapdir/amd_site":
      owner   => root,
      group   => 0,
      content => template("automount/amd_site.erb"),
      mode    => 0644,
      notify  => Exec["reload amd"],
    }
    file {"$mapdir/amd_mirror":
      owner   => root,
      group   => 0,
      content => template("automount/amd_mirror.erb"),
      mode    => 0644,
      notify  => Exec["reload amd"],
    }
    # usually we use the stock map
    file {"$mapdir/amd_nethome":
      owner  => root,
      group  => 0,
      source => "puppet:///modules/automount/$homemap",
      mode   => $hmapperm,
      notify => Exec["reload amd"],
    }
    file {"$mapdir/amd.conf":
      owner   => root,
      group   => 0,
      content => template("automount/amd.conf.erb"),
      mode    => 0644,
      notify  => Exec["restart amd"],
    }
    # reconfig amd to use our maps
    case $::operatingsystem {
      'FreeBSD': {
        augeas { "rc.conf: setting amd options":
          changes => [
            "set /files/etc/rc.conf/amd_flags '\"-F /etc/amd.conf -l syslog\"'",
          ],
          notify  => Exec["restart amd"],
        }
      }
    }
  }
}
