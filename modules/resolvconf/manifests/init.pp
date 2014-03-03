class resolvconf (
  $file = hiera('resolvconf::file'),
  $nameservers = hiera('nameservers'),
  $domain = hiera('dnsdomain'),
) {
  # this class mostly exists to blow up ubuntu's resolvconf idiocy
  require stdlib

  $servcount = size($nameservers)
  $random = fqdn_rand($servcount,62467)

  file {$file:
    owner	=> root,
    group	=> 0,
    mode	=> 0644,
    ensure	=> present,
    content	=> template("resolvconf/resolv.conf.erb"),
  }
}
