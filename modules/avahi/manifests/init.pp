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
       if ($pkgng_enabled) {
         # install avahi metaport now
         package{ 'net/avahi': ensure => installed }
       }
       # kick DBUS, then avahi
       package{ 'devel/dbus': ensure => installed }
       
       avahi::fbstartavahi { 'avahi-daemon': }
       service{"dbus": enable => true, ensure => running, } ~> service{"avahi-daemon": enable => true, } ~> Fbstartavahi[ 'avahi-daemon' ]
    }
  }
}
