class nameserver (
  $upstreams = [ '8.8.8.8', '8.8.4.4' ],
  $listen_ipv4 = '127.0.0.1',
  $listen_ipv6 = '::1',
  $template,
) {
  # stand up an authoritative name server
  case $::osfamily {
    'RedHat' : {
        $config   = '/var/named/chroot/etc/named.conf'
        $packages = [ 'bind-chroot' ]
      if versioncmp( $::operatingsystemrelease, "7") >= 0 {
        $service  = 'named-chroot'
      } else {
        $service  = 'named'
      }
    }
  }

  # template specific crap
  $zones = hiera_hash("nameserver::zones")

  ensure_packages($packages)

  file{$cfg:
    ensure  => present,
    content => template("nameserver/$template.conf.erb"),
    mode    => "0640",
    owner   => 0,
    group   => "named",
  }
}
