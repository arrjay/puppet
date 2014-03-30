class netboot (
) {
  require dhcpd
  require inetd::tftpd

  $site_mirror = "/site/mirror/"

  define tftplink (
    $suffix = undef,
    $source,
    $ip = $title,
  ) {
    $ip2hex = ip2hex($ip)
    file{"tftp boot: ($ip)":
      ensure	=> link,
      target	=> "./$source",
      path	=> "$inetd::tftpd::tftproot/$ip2hex",
    }
    if $suffix {
      file{"tftp boot: ($ip).$suffix":
        ensure	=> link,
        target	=> "./$source",
        path	=> "$inetd::tftpd::tftproot/$ip2hex.$suffix",
      }
    }
  }
}
