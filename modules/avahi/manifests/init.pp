class avahi {
  define fbstartavahi {
    $svccmd = hiera('service',undef)
      exec{"$hwmonitoring::svccmd avahi-daemon restart":
      refreshonly => true,
      unless      => "/bin/pgrep -u avahi"
    }
  }
  case $::operatingsystem {
    'FreeBSD': {
       # kick DBUS, then avahi
       avahi::fbstartavahi { 'avahi-daemon': }
       service{"dbus": enable => true, ensure => running, } ~> service{"avahi-daemon": enable => true, } ~> Fbstartavahi[ 'avahi-daemon' ]
    }
  }
}
