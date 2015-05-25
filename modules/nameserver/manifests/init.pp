# wrap around the bind class to do exactly what we want.
class nameserver (
  $forwarders  = [ '8.8.8.8', '8.8.4.4' ],
  $views       = {},
  $includes    = [],
) {
  class { bind: chroot => true }
  # oh, wow. comment all of this out until I upgrade the puppetmaster. epel is breathtakingly dumb.
  # puppet bug #20199
  #if ( empty($views) ) {
    $_views    = hiera_hash('nameserver::views')
  #}
  #} else {
  #  $_views    = $views
  #}
  #if ( empty($includes) ) {
    $_includes = hiera_array('nameserver::includes')
  #} else {
  #  $_includes = $includes
  #}

  # delete the non-chroot config on c7 to ensure we don't start non-chrooted named
  case $::osfamily {
   'RedHat': {
     if versioncmp($operatingsystemmajrelease,"7") >= 0 {
       file{'/etc/named.conf':
         ensure => absent,
       }
     }
   }
  }

  bind::server::conf { '/var/named/chroot/etc/named.conf':
    forwarders => $forwarders,
    views      => $_views,
    includes   => $_includes,
    recursion  => false,
  }
}
