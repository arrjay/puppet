# we do not auto-hook zonefile to named config.
define zonefile (
  $template		= $title,
  $admin		= $nameserver::zonedefaults['admin'],
  $minttl		= undef, # 1d
  $serial		= undef, # 42
  $refresh		= undef, # 2d
  $retry		= undef, # 1d
  $expiry		= undef, # 1w
  $nxttl		= undef, # 12h
  $domain		= undef, # useful for PTR templates :)
  $nameservers	= undef,
  $copy		= undef, # useful to tie PTR templates to forward templates...
  $hierasrc		= undef, # set this to true if you're abusing hiera ;)
) {
  # go fishing for a zone definition to copy bits from
  if $copy == undef {
    if $nameserver::zonedata[$title] and $nameserver::zonedata[$title]['copy'] {
      $_copy = $nameserver::zonedata[$title]['copy']
    }
  }

  # yuck. puppet/hiera directly gives us an error if we try to chase a hash tree that is missing a parent. so, do this.
  if $serial == undef {
    if $nameserver::zonedata[$title] and $nameserver::zonedata[$title]['serial'] {
      $_serial = $nameserver::zonedata[$title]['serial']
    } elsif $nameserver::zonedata[$_copy] and $nameserver::zonedata[$_copy]['serial'] {
      $_serial = $nameserver::zonedata[$_copy]['serial']
    } else {
      $_serial = '42'
    }
  } else {
    $_serial = $serial
  }

  if $minttl == undef {
    if $nameserver::zonedata[$title] and $nameserver::zonedata[$title]['minttl'] {
      $_minttl = $nameserver::zonedata[$title]['minttl']
    } elsif $nameserver::zonedata[$_copy] and $nameserver::zonedata[$_copy]['minttl'] {
      $_minttl = $nameserver::zonedata[$_copy]['minttl']
    } else {
      $_minttl = '1d'
    }
  } else {
    $_minttl = $minttl
  }

  if $refresh == undef {
    if $nameserver::zonedata[$title] and $nameserver::zonedata[$title]['refresh'] {
      $_refresh = $nameserver::zonedata[$title]['refresh']
    } elsif $nameserver::zonedata[$_copy] and $nameserver::zonedata[$_copy]['refresh'] {
      $_refresh = $nameserver::zonedata[$_copy]['refresh']
    } else {
      $_refresh = '2d'
    }
  } else {
    $_refresh = $refresh
  }

  if $retry == undef {
    if $nameserver::zonedata[$title] and $nameserver::zonedata[$title]['retry'] {
      $_retry = $nameserver::zonedata[$title]['retry']
    } elsif $nameserver::zonedata[$_copy] and $nameserver::zonedata[$_copy]['retry'] {
      $_retry = $nameserver::zonedata[$_copy]['retry']
    } else {
      $_retry = '1d'
    }
  } else {
    $_retry = $retry
  }

  if $expiry == undef {
    if $nameserver::zonedata[$title] and $nameserver::zonedata[$title]['expiry'] {
      $_expiry = $nameserver::zonedata[$title]['expiry']
    } elsif $nameserver::zonedata[$_copy] and $nameserver::zonedata[$_copy]['expiry'] {
      $_expiry = $nameserver::zonedata[$_copy]['expiry']
    } else {
      $_expiry = '1w'
    }
  } else {
    $_expiry = $expiry
  }

  if $nxttl == undef {
    if $nameserver::zonedata[$title] and $nameserver::zonedata[$title]['nxttl'] {
      $_expiry = $nameserver::zonedata[$title]['nxttl']
    } elsif $nameserver::zonedata[$_copy] and $nameserver::zonedata[$_copy]['nxttl'] {
      $_nxttl = $nameserver::zonedata[$_copy]['nxttl']
    } else {
      $_nxttl = '12h'
    }
  } else {
    $_nxttl = $nxttl
  }

  if $domain == undef {
    if $nameserver::zonedata[$title] and $nameserver::zonedata[$title]['domain'] {
      $_domain = $nameserver::zonedata[$title]['domain']
    } elsif $nameserver::zonedata[$_copy] and $nameserver::zonedata[$_copy]['domain'] {
      $_domain = $nameserver::zonedata[$_copy]['domain']
    } # don't set domain if not found
  } else {
    $_domain = $domain
  }

  if $nameservers == undef {
    if $nameserver::zonedata[$title] and $nameserver::zonedata[$title]['nameservers'] {
      $_nameservers = $nameserver::zonedata[$title]['nameservers']
    } elsif $nameserver::zonedata[$_copy] and $nameserver::zonedata[$_copy]['nameservers'] {
      $_nameservers = $nameserver::zonedata[$_copy]['nameservers']
    } else {
      $_nameservers = [ 'localhost.' ]
    }
  } else {
    $_nameservers = $nameservers
  }

  file { "$nameserver::dir/master/$title.db":
    ensure  => present,
    path    => "$nameserver::dir/master/$title.db",
    content => template("nameserver/$template.erb"),
    mode    => '0644',
    owner   => 'root',
    group   => $group,
    notify  => Exec["reload named"],
  }
}
