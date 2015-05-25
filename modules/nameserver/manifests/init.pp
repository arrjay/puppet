# wrap around the bind class to do exactly what we want.
class nameserver (
  $forwarders = [ '8.8.8.8', '8.8.4.4' ],
  # puppet bug #20199
  $views      = hiera_hash('nameserver::views'),
  $includes   = hiera_array('nameserver::includes'),
) {
  class { bind: chroot => true }

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
    views      => $views,
    includes   => $includes,
  }
}
