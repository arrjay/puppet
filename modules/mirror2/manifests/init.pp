class mirror2 (
  $dest         = hiera('mirror2::destination'),
  $rsync_source = hiera('mirror2::rsync_source'),
) {
  # if selinux is around, reset ALL THE FILE CONTEXTS here.
  if $::selinux {
    # this will force you to write out a selinux config decision and let hiera deal with that.
    $seconfig = hiera('selinux::mode')
    require selinux

    # NOTE: this will configure the filecontext for all *new* files, you may still need restorecon -R on the mirror dir to clean up.
    selinux::fcontext{'set-mirrors-httpd_t':
      context  => 'httpd_sys_content_t',
      pathname => "$dest(/.*)?",
    }
  }
}
