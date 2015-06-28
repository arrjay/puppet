class dhcpd::dyn (
  $keyfile,
  $target_ns,
  $domain,
  $reverse_delegation,
) {
  file {"/usr/local/bin/update-dns.sh":
    ensure  => present,
    owner   => 'root',
    group   => 0,
    mode    => '0755',
    source  => 'puppet:///modules/dhcpd/update-dns.sh',
  }
  file {"/usr/local/etc/update-dns.conf":
    ensure  => present,
    owner   => 'root',
    group   => 0,
    mode    => '0644',
    content => template('dhcpd/update-dns.conf.erb'),
  }
}
