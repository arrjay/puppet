class httpd (
  $host_ssl_cert = hiera('httpd::ssl_cert',undef)
) {
  include intca
  # if we have a SSL cert for this host, save it somewhere semi-useful :)
  if $host_ssl_cert {
    file { "${intca::certdir}/${$::fqdn}.crt":
      ensure  => present,
      content => $host_ssl_cert,
      mode    => 0600,
      owner   => root,
      group   => 0,
    }
  }
}
