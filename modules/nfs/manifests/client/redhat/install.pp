# Shamefully stolen from https://github.com/frimik/puppet-nfs
# refactored a bit

class nfs::client::redhat::install {

  Package {
    before => Class['nfs::client::redhat::configure']
  }
  package { 'nfs-utils':
    ensure => present,
  }

  if $::nfs::client::redhat::params::osmajor == 6 or $::nfs::client::redhat::params::osmajor == 7 {
    ensure_packages('rpcbind')
  } elsif $::nfs::client::redhat::params::osmajor == 5 {
    ensure_packages('portmap')
  }
}
