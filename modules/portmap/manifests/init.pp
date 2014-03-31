class portmap (
  $bind_ip = hiera('portmap::bind_ip',undef),
) {
  $svccmd = hiera('service')

  case $::osfamily{
    'FreeBSD': {
      $service = rpcbind
    }
  }

  if $bind_ip {
    case $::osfamily{
      'FreeBSD': {
        augeas{ "rc.conf: rpcbind_flags":
          changes	=> [ "set /files/etc/rc.conf/rpcbind_flags '\"-h $bind_ip\"'", ],
          notify	=> Exec['restart portmap'],
        }
      }
    }
  }

  exec{'restart portmap':
    refreshonly	=> true,
    command	=> "$svccmd $service restart",
  }
}
