define samba::share(
  $share = $title,
  $path,
  $description = undef,
  $browseable = true,
  $printable = false,
  $writeable = false,
  $public = false,
  $create_mask = undef,
  $dir_mask = undef,
  $hide_unreadable = false,
) {
  include samba

  if $share == "global" {
    fail('you may not have a samba share named global!')
  }

  concat::fragment{"$samba::config: [share] - $share":
    target  => 'smb.conf',
    content => template('samba/share.erb'),
    order   => $samba::share_order,
  }
}
