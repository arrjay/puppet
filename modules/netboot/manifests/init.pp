class netboot (
) {
  require dhcpd
  require inetd::tftpd

  $site_mirror = "/site/mirror/"
}
