class netboot::sparc_common (
  $root_export = hiera('netboot::sparcnfsroot'),
  $root_opts   = hiera('netboot::sparcnfsroot_opts'),
) {
  include rarpd
  include netboot
  include nfs::server::nfs_v2

  if versioncmp($::operatingsystemmajrelease,'7') >= 0 {
    include rpmrepo::arrjay_rpc
    ensure_packages('rpcbind')	# NOTE: we can't assert latest here unless we find all the other ensure_packages
  }

  file{$root_export:
    ensure => directory,
    mode   => '0755',
  }

  nfs::server::export{$root_export:
    clients => $root_opts,
  }

}
