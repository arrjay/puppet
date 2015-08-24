class netboot::sparc_common (
  $root_export = hiera('netboot::sparcnfsroot'),
  $root_opts   = hiera('netboot::sparcnfsroot_opts'),
) {
  include rarpd
  include netboot
  include nfs::server

  file{$root_export:
    ensure => directory,
    mode   => '0755',
  }

  nfs::server::export{$root_export:
    clients => $root_opts,
  }

}
