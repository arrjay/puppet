class mirror2 (
  $dest         = hiera('mirror2::destination'),
  $rsync_source = hiera('mirror2::rsync_source'),
) {
  # if selinux is around, reset ALL THE FILE CONTEXTS here.
  if $::selinux {
    # this will force you to write out a selinux config decision and let hiera deal with that.
    $seconfig = hiera('selinux::mode')
    require selinux
  }
}
