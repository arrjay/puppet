class netboot::debian_ip2x (
  $version = hiera('netboot::uri::debian_ip2x','http://mirrors.kernel.org/debian/dists/wheezy/main/installer-mips/current/images/r4k-ip22/netboot-boot.img'),
  $outfile = hiera('netboot::file::debian_ip2x','ip22-debian-wheezy.img'),
) {
  require netboot
  require netboot::ip2x_common

  exec{"fetch $version as $outfile":
    command => "/usr/bin/fetch $version -o $outfile",
    cwd => $inetd::tftpd::tftproot,
    creates => "$inetd::tftpd::tftproot/$outfile",
  }
}
