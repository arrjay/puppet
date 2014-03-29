class nameserver (
  $ipv4_listen = hiera('nameserver::ipv4_listener','127.0.0.1'),
  $ipv6_listen = hiera('nameserver::ipv6_listener','::1'),
  $zonefiles = hiera('nameserver::zonefiles',{ 'localhost-forward.zone' => { 'nameservers' => ['localhost.'] },
                                               'localhost-reverse.zone' => { 'nameservers' => ['localhost.'] } }),
  $views = hiera('nameserver::views',{ self => 
						{ services => ['127.0.0.1', '::1'],
						  recursion => yes,
						  zones => { localhost => { type => 'master',
									    source => 'localhost-forward.zone',
									  },
							     '127.in-addr.arpa' => { type => 'master',
										source => 'localhost-reverse.zone',
									},
							},
						}
				      }),
  $miscopts = hiera('nameserver::miscopts',undef),
  $files = hiera('nameserver::files',undef),
) {
  #fail($zonefiles['localhost-forward.zone'])
  # creates an authoritative/caching nameserver using BIND.
  case $::operatingsystem {
    'FreeBSD': {
      $chroot       = "/var/named"		# path for chroot - create if nonexistent
      $_osrel = split($::operatingsystemrelease,'-')	# 9.0
      if ($_osrel[0] > 9) {
        $pkg        = "bind99"			# package name for named (pkgng)
        $dir        = "/var/named/etc/namedb"	# path for auxiliary named files
        $_chrootref = "/etc/namedb"		# where named sees data internal to chroot
        $chkconf    = "/usr/local/sbin/named-checkconf" # path to named.conf checker
        # actually make the named directory here :x
        file {['/var/named','/var/named/etc','/var/named/etc/namedb']:
          ensure => directory,
	}
	# cheat - link chrootref to real chroot dir
        file{$_chrootref:
          ensure => link,
          target => $dir,
        }
        # *really cheat* - link /usr/local/etc/namedb to real chroot dir
        # because the rc script is maintained by morons
        file{"/usr/local/etc/namedb":
          ensure => link,
          target => $dir,
          force  => true,
        }
        # no, really...
        file{["$chroot/usr","$chroot/usr/local","$chroot/usr/local/etc"]:
          ensure => directory,
        }
        file{"$chroot/usr/local/etc/namedb":
          ensure => link,
          target => "/etc/namedb",	# because you read this link from *inside*!
        }
        file{"/var/run/named":
          ensure => link,
          target => "$chroot/var/run/named",
          force  => true,
        }
	# mangle rc.conf to work-ish
	augeas{"rc.conf: named_flags":
          changes => [
            "set /files/etc/rc.conf/named_flags '\"-t $chroot\"'",
          ],
        }
        #augeas{"rc.conf: named_
      } else {
        $dir        = "/etc/namedb"		# path for auxiliary named files	
        $_chrootref = $dir			# where named sees data internal to chroot
        $chkconf    = "/usr/sbin/named-checkconf" # path to named.conf checker
      }
      $cfg          = "$dir/named.conf"		# path to named config
      $wrkdir       = "$_chrootref/working"	# path for transient named data
      $pidfile      = "/var/run/named/pid"	# path to pid-keeping file
      $dumpfile     = "/var/dump/named_dump.db" # path to named db dump file
      $statsfile    = "/var/stats/named.stats"	# path to named statistics tracking file
      $svc          = "named"			# service hook for named	
      $group        = "bind"			# named ownership group
      $owner        = "bind"			# named ownsership user
      $_named_ddirs = [
        "$dir/slave",				# slave zone storage
        "$chroot/var/named/dynamic",		# a grouping of directories (to resolve a full path)
        "$chroot/var/named",			#  of where named keeps dynamic data.
      ]
      $_named_rdirs = [
        "$chroot/var",	 			# the upper half of the named path - to be root owned
        "$dir/master",				# actually the directory to pull master zone files from
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
  $zonedefaults = hiera_hash('nameserver::zonedefaults')
  $zonedata = hiera_hash('nameserver::zonedata')

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

  # Fetch zones from server params if we can
  create_resources( zonefile, $zonefiles )

  # inc is a subset of the nameserver config file, restart named if these change
  define inc (
    $template = "nameserver/$title.erb",
  ) {
    file { "$nameserver::dir/$title":
      ensure  => present,
      path    => "$nameserver::dir/$title",
      content => template("nameserver/$template"),
      mode    => '0644',
      owner   => 'root',
      group   => $group,
      notify  => Exec["restart named"],
    }
  }

  if $files {
    create_resources( inc, $files )
  }

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
