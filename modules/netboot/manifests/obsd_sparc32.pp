class netboot::obsd_sparc32 (
  $version	= hiera('netboot::obsd_sparc32_ver','5.4'),
  $hosts	= hiera('netboot::obsd_sparc32_hosts',undef),
) {
  require rarpd
  require inetd::tftpd

  $interfaces = hiera_hash("interface")

  $filepath = "$netboot::site_mirror/OpenBSD/$version/sparc"

  exec{"copy bsd.rd to netboot":
    command => "/bin/cp -p $filepath/bsd.rd $inetd::tftpd::tftproot/obsd.$version.rd",
    unless  => "/usr/bin/diff $filepath/bsd.rd $inetd::tftpd::tftproot/obsd.$version.rd",
  }

  define obsd_sparc32_tftplink (
    $host = $title,
  ) {
    $interfaces = $netboot::obsd_sparc32::interfaces
    $ip = $interfaces[$host]['ip']
    netboot::tftplink{"$ip": source => "obsd.$netboot::obsd_sparc32::version.rd", suffix => "SUN4M"}
  }

  if $hosts {
    obsd_sparc32_tftplink{$hosts:}
  }
}
