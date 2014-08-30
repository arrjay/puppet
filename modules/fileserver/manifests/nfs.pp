class fileserver::nfs (
) {
  # kick a basic nfs server up
  include fileserver
  include portmap

  case $::osfamily {
    'RedHat' : {
      $packages = [ 'nfs-utils' ]
      $services = [ 'rpcbind', 'nfs-server' ]
      $exports  = '/etc/exports'
    }
    'FreeBSD' : {
      $exports  = '/etc/exports'
      $services = [ 'nfsd', 'mountd', 'lockd' ]
    }
  }

  file{$exports:
    ensure => present,
    owner  => root,
    group  => 0,
    mode   => 0644,
  }

  if $packages {
    package {$packages: ensure => installed}
  }

  service {$services: enable => true}
}
