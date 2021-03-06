class netboot (
) {
  include tftp
  # in lieu of a better idea, manage tftp links here.
  $hosts = hiera_hostlist()
  $hosts.each |$host| {
    $tftpsource = hiera_hostbootfile($host)
    $hostip = hiera_hostip($host)
    $hostsfx = hiera_hostbootsfx($host)
    if $tftpsource != undef {
      $tftplink = { $hostip => { 'source' => $tftpsource, 'suffix' => $hostsfx } }
      create_resources('netboot::tftplink',$tftplink)
    }
    $bootparams = hiera_hostbootparams($host)
    if $bootparams != undef {
      $dbootparams = { $host => { 'params' => $bootparams } }
      create_resources('netboot::bootparams',$dbootparams)
    }
  }
}
