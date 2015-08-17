class netboot (
) {
  include tftp
  # in lieu of a better idea, manage tftp links here.
  $hosts = hiera_hostlist()
  $hosts.each |$host| {
    $tftpsource = hiera_hostbootfile($host)
    $hostip = hiera_hostip($host)
    if $tftpsource != undef {
      $tftplink = { $hostip => { 'source' => $tftpsource } }
      create_resources('netboot::tftplink',$tftplink)
    }
  }
}
