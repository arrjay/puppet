class nfs::server::nfs_v2(
) {
  include nfs::server
  case $::osfamily {
    'RedHat': {
      if (versioncmp($::operatingsystemmajrelease, '7') >= 0) {
        # don't need to even explicitly enable here, just restart after config wrangle.
        service{'nfs-config': }
        $cfgdeps = [Service['nfs-config'], Service['nfs-server']]
      } else {
        $cfgdeps = [Service['nfs']]
      }

      # use augeas to twiddle the config
      augeas{'/etc/sysconfig/nfs: enable v2 nfsd':
        context => '/files/etc/sysconfig/nfs',
        changes => [
          "set RPCNFSDARGS '\"-V 2\"'",
        ],
        notify => $cfgdeps,
      }
    }
  }
}
