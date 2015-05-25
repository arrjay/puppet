class nameserver (
  $upstreams = [ '8.8.8.8', '8.8.4.4' ],
  $listen_ipv4 = '127.0.0.1',
  $listen_ipv6 = '::1',
) {
  # stand up an authoritative name server
  case $::osfamily {
    'RedHat' : {
        $packages = [ 'bind-chroot' ]
      if versioncmp( $::operatingsystemrelease, "7") >= 0 {
        $service  = 'named-chroot'
      } else {
        $service  = 'named'
      }
    }
  }

  ensure_packages($packages)
}
