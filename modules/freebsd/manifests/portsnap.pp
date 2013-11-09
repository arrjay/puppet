# Init FreeBSD's portsnap, install syncronization cron job
class freebsd::portsnap {
  require freebsd::syncportopts
  # setup portsnap via cron, not puppet schedules
  # NOTE: this command takes a while
  exec { "portsnap extract":
    command     => "/usr/sbin/portsnap extract",
    refreshonly => true,
    timeout     => 900,
  }
  exec { "portsnap fetch":
    command => "/bin/sh -c '(/bin/sleep 15 && /bin/pkill -n sleep) & (/usr/sbin/portsnap cron; exit 0)'",
    creates => "/var/db/portsnap/files",
    notify  => Exec["portsnap extract"],
  }

  # Now that we've handled initial setup, install the cron job
  cron { "portsnap":
    command  => "/usr/sbin/portsnap cron",
    user     => root,
    hour     => 2,
    minute   => 10,
    require  => Exec["portsnap fetch"],
  }

  # We can pull portsnap update immediately before going a packagin'
  exec { "portsnap update":
    command      => "/usr/sbin/portsnap update",
    refreshonly  => true,
    timeout      => 300,
    require      => Vcsrepo["/var/db/ports"],
  }
}
