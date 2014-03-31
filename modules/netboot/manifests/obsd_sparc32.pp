class netboot::obsd_sparc32 (
  $version	= hiera('netboot::obsd_sparc32_ver','5.4'),
  $hosts	= hiera('netboot::obsd_sparc32_hosts',undef),
) {
  require rarpd
  require inetd::tftpd
  include bootparamd

  $interfaces = hiera_hash("interface")

  $filepath = "$netboot::site_mirror/OpenBSD/$version/sparc"

  exec{"copy bsd.rd to netboot":
    command => "/bin/cp -p $filepath/bsd.rd $inetd::tftpd::tftproot/obsd.$version.rd",
    unless  => "/usr/bin/diff $filepath/bsd.rd $inetd::tftpd::tftproot/obsd.$version.rd",
  }

  exec{"copy boot.net to netboot":
    command => "/bin/cp -p $filepath/boot.net $inetd::tftpd::tftproot/obsd.$version.boot.net",
    unless  => "/usr/bin/diff $filepath/boot.net $inetd::tftpd::tftproot/obsd.$version.boot.net",
  }

  define obsd_sparc32_tftplink (
    $host = $title,
  ) {
    $interfaces = $netboot::obsd_sparc32::interfaces
    $ip = $interfaces[$host]['ip']
    netboot::tftplink{"$ip": source => "obsd.$netboot::obsd_sparc32::version.boot.net", suffix => "SUN4M"}
    bootparamd::line{"$host": content => "$host root=$::hostname:/m/OpenBSD/$netboot::obsd_sparc32::version/sparc/\n"}
  }

  if $hosts {
    obsd_sparc32_tftplink{$hosts:}
  }
}
