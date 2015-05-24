class resolvconf (
  $file = '/etc/resolv.conf',
  $nameservers,
  $domain,
  $manage_dhclient = false,
  $dhclient_cfg = '/etc/dhclient.conf',
) {
  # this class mostly exists to blow up ubuntu's resolvconf idiocy

  $ns_shuffled = fqdn_rotate($nameservers)
  $ns_string = join($ns_shuffled, ",")

  file {$file:
    owner	=> root,
    group	=> 0,
    mode	=> 0644,
    ensure	=> present,
    content	=> template("resolvconf/resolv.conf.erb"),
  }

  if ($manage_dhclient) {
    $dhcp_opt_string = "supersede domain-name-servers $ns_string;"
    # augeas lens for dhcpd doesn't handle supersede - https://bugs.launchpad.net/ubuntu/+source/augeas/+bug/1193176
    exec {"$dhclient_cfg: add 'supersede domain-name-servers' opt":
      command => "echo '$dhcp_opt_string' >> $dhclient_cfg",
      unless  => "grep -q '^supersede domain-name-servers' $dhclient_cfg",
    }
    exec {"$dhclient_cfg: reset 'supersede domain-name-servers' opt":
      command => "perl -pi -e 's/supersede domain-name-servers.*/$dhcp_opt_string/' $dhclient_cfg",
      unless  => "grep -q '^$dhcp_opt_string' $dhclient_cfg",
    }
  }
}
