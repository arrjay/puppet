class resolvconf (
  $file = '/etc/resolv.conf',
  $nameservers,
  $domain,
  $manage_dhclient = false,
  $dhclient_cfg = '/etc/dhclient.conf',
) {
  # this class mostly exists to blow up ubuntu's resolvconf idiocy

  $servcount = size($nameservers)
  $random = fqdn_rand($servcount,62467)

  file {$file:
    owner	=> root,
    group	=> 0,
    mode	=> 0644,
    ensure	=> present,
    content	=> template("resolvconf/resolv.conf.erb"),
  }

  if ($manage_dhclient) {
    augeas{"$dhclient_cfg: supersede nameservers"
      changes => [
        "set /files$dhclient_cfg/supersede/domain-name-servers = \"$nameservers\"",
      ],
    }
  }
}
