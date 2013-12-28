class nfs::server {
  include fileserver

  case $::operatingsystem {
    'FreeBSD': {
      $exports = '/etc/exports'
      $nfsd    = 'nfsd'
      $mountd  = 'mountd'
      $lockd   = 'lockd'
    }
  }

  file{$exports:
    ensure => present,
    owner  => root,
    group  => 0,
    mode   => 0744,
  }

  service { ["$nfsd", "$mountd", "$lockd"]: enable => true, ensure => "running", }
}
