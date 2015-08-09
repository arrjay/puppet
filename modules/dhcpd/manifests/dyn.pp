class dhcpd::dyn (
  $keyfile,
  $target_ns,
  $domain,
  $reverse_delegation,
) {
  file {"/usr/local/bin/update-dns.sh":
    ensure  => present,
    mode    => '0755',
    source  => 'puppet:///modules/dhcpd/update-dns.sh',
  }
  file {"/usr/local/etc/update-dns.conf":
    ensure  => present,
    content => template('dhcpd/update-dns.conf.erb'),
  }
}
