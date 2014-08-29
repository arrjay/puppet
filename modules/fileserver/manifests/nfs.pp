class fileserver::nfs (
) {
  # kick a basic nfs server up
  case $::osfamily {
    'RedHat' : {
      $packages = [ 'nfs-utils' ]
      $services = [ 'rpcbind', 'nfs-server' ]
    }
  }
  package {$packages: ensure => installed}
  service {$services: enable => true}
}
