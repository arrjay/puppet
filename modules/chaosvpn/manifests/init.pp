class chaosvpn (
  $privkey,	# ssl private key for chaosvpn
  $router_ip,	# local lan ip for routing into chaosvpn
  $nodename,	# chaosvpn node name - needs to match your privkey.
) {
  case $::operatingsystem {
    'Debian': {
      include apt
      apt::key{'sdinet':
        id       => '5AF7BE4EB73401B7C4B2652A157614093BD8041F',
        content  => hiera('chaosvpn::sdinet_key'),
      }
      apt::source{'chaosvpn':
        comment  => 'sdinet precompiled chaosvpn binaries',
        location => 'http://debian.sdinet.de',
        release  => $::lsbdistcodename,
        repos    => 'chaosvpn',
      }
      ensure_packages(['chaosvpn'])
      file{'/etc/tinc/chaos':
        ensure  => directory,
        owner   => 'root',
        group   => 0,
        mode    => '0755',
        require => Package['chaosvpn'],
      }
      file{'/etc/tinc/chaos/rsa_key.priv':
        ensure  => present,
        owner   => 'root',
        group   => 0,
        mode    => '0700',
        content => $privkey,
        require => File['/etc/tinc/chaos'],
      }
      file{'/etc/tinc/chaosvpn.conf':
        ensure  => present,
        owner   => 'root',
        group   => 0,
        mode    => '0744',
        content => template('chaosvpn/chaosvpn.conf.erb'),
        require => Package['chaosvpn'],
      }
      file{'/etc/default/chaosvpn':
        ensure  => present,
        owner   => 'root',
        group   => 0,
        mode    => '0744',
        source  => 'puppet:///modules/chaosvpn/chaosvpn.defaults',
      }
    }
  }
}
