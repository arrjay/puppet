class netboot::yaboot(
  $source = hiera('netboot::uri::yaboot_bin'),
) {
  exec{"get yaboot binary":
    command => "/usr/bin/fetch $source",
    cwd     => $inetd::tftpd::tftproot,
    creates => "$inetd::tftpd::tftproot/yaboot",
  }
}
