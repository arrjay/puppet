class nameserver (
) {
  # creates an authoritative/caching nameserver using BIND.
  case $::operatingsystem {
    'FreeBSD': {
      $_osrel = split($::operatingsystemrelease,'-')	# 9.0
      if ($_osrel[0] > 9) {
        $pkg        = "net/bind9"		# package name for named
      }
      $cfg          = "/etc/namedb/named.conf"	# path to named config
      $dir          = "/etc/namedb"		# path for auxiliary named files	
      $wrkdir       = "/etc/namedb/working"	# path for transient named data
      $pidfile      = "/var/run/named/pid"	# path to pid-keeping file
      $dumpfile     = "/var/dump/named_dump.db" # path to named db dump file
      $statsfile    = "/var/stats/named.stats"	# path to named statistics tracking file
      $chkconf      = "/usr/sbin/named-checkconf" # path to named.conf checker
      $svc          = "named"			# service hook for named	
      $group        = "bind"			# named ownership group
      $owner        = "bind"			# named ownsership user
      $_chrootref   = $dir			# where named sees data internal to chroot
      $_named_ddirs = [
        "/etc/namedb/slave",			# slave zone storage
        "/var/named/var/named/dynamic",		# a grouping of directories (to resolve a full path)
        "/var/named/var/named",			#  of where named keeps dynamic data.
      ]
      $_named_rdirs = [
        "/var/named/var", 			# the upper half of the named path - to be root owned
        "/etc/namedb/master",			# actually the directory to pull master zone files from
      ]
    }
  }

  if $pkg {
    package{$pkg: ensure => installed}
  }

  # create the dynamic data directories
  file {$_named_ddirs:
    ensure => directory,
    owner  => $owner,
  }
  file {$_named_rdirs:
    ensure => directory,
    owner  => 'root',
  }
  file {$wrkdir:
    ensure => directory,
    owner  => $owner,
  }

  # to be called if the actual named config changes
  exec { "restart named":
    refreshonly => true,
    command     => "/usr/sbin/service $svc restart",
    subscribe   => [ File[$cfg], Service[$svc] ],
    onlyif      => "$chkconf $cfg",
  }

  # to be called if the zone data changes
  exec { "reload named":
    refreshonly => true,
    command     => "/usr/sbin/service $svc reload",
  }

  file { "namedata/root.hints":
    ensure => present,
    path   => "$dir/root.hints",
    source => "puppet:///modules/nameserver/root.hints",
    mode   => '0644',
    owner  => 'root',
    group  => $group,
    notify => Exec["reload named"],
  }

  # collate default zone data, zone defaults
  # zones are defined outside the nameserver params, so you can share zones that way.
  $zonedefaults = hiera_hash('zonedefaults')
  $zonedata = hiera('zonedata')
  $params = hiera_hash('nameserver')
  $nsgroup = hiera_hash('nsgroup')

  # we do not auto-hook zonefile to named config.
  define zonefile (
    $template = undef,
    $admin    = $nameserver::zonedata[$title]['admin'],
    $minttl   = $nameserver::zonedata[$title]['ttl'],
    $serial   = $nameserver::zonedata[$title]['serial'],
    $refresh  = $nameserver::zonedata[$title]['refresh'],
    $retry    = $nameserver::zonedata[$title]['retry'],
    $expiry   = $nameserver::zonedata[$title]['expiry'],
    $nxttl    = $nameserver::zonedata[$title]['nxttl'],
    $copy     = $nameserver::zonedata[$title]['copy'],
    $domain   = $nameserver::params['zones'][$title]['ptrdomain'],
    $type     = $nameserver::zonedata[$title]['type'],
  ) {
    # I'm not entirely sure why puppet needed hand-holding to look this one up
    $_tvar = $nameserver::params['zones'][$title]['template']
    # load in zone defaults if we didn't have zone data
    # load in the zone copy data first
    if $copy != undef {
      $nameservers = $nameserver::zonedata[$copy]['nameservers']
      if $serial == undef { $_serial = $nameserver::zonedata[$copy]['serial'] } else { $_serial = $nameserver::zonedefaults['serial'] }
    } else {
      # do the regular variable copy now
      # pick up nameservers
      $nameservers = $nameserver::zonedata[$title]['nameservers']
      if $serial == undef { $_serial = $nameserver::zonedefaults['serial'] } else { $_serial = $serial }
    }
    if $template == undef { $_template = "nameserver/${_tvar}.zone.erb" } else { $_template = $template }
    if $admin == undef { $_admin = $nameserver::zonedefaults['admin'] } else { $_admin = $admin }
    if $minttl == undef { $_minttl = $nameserver::zonedefaults['ttl'] } else { $_minttl = $minttl }
    if $refresh == undef { $_refresh = $nameserver::zonedefaults['refresh'] } else { $_refresh = $refresh }
    if $retry == undef { $_retry = $nameserver::zonedefaults['retry'] } else { $_retry = $retry }
    if $expiry == undef { $_expiry = $nameserver::zonedefaults['expiry'] } else { $_expiry = $expiry }
    if $nxttl == undef { $_nxttl = $nameserver::zonedefaults['nxttl'] } else { $_nxttl = $nxttl }
    if $type == undef { $_type = master } else { $_type = $type }
    file { "$nameserver::dir/$_type/$title.db":
      ensure  => present,
      path    => "$nameserver::dir/$_type/$title.db",
      content => template($_template),
      mode    => '0644',
      owner   => 'root',
      group   => $group,
      notify  => Exec["reload named"],
    }
  }

  # Fetch zones from server params if we can
  $zones = keys($params['zones'])
  zonefile{$zones:}

  # inc is a subset of the nameserver config file, restart named if these change
  define inc (
    $template = "nameserver/$title.erb",
  ) {
    file { "$nameserver::dir/$title":
      ensure  => present,
      path    => "$nameserver::dir/$title",
      content => template($template),
      mode    => '0644',
      owner   => 'root',
      group   => $group,
      notify  => Exec["restart named"],
    }
  }

  # Pick up any additional pieces
  $incs = $params['inc']
  if $incs != undef {
    inc{$incs:}
  }

  # Fetch server params now
  $addresses = keys($params['addresses'])
  $views = keys($params['views'])

  # Oh hey...write the named config.
  file { "$cfg":
    ensure  => present,
    mode    => '0644',
    owner   => 'root',
    group   => 0,
    content => template("nameserver/named.conf.erb"),
  }

  # start named
  service { "$svc": enable => true }
}
