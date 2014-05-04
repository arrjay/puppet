class netboot::obsd_alpha(
  $version = hiera('netboot::obsd_alpha_ver','5.5'),
  $hosts   = hiera('netboot::obsd_alpha_hosts',undef),
) {
  require netboot
  require netboot::jumpstart_common	# used for serving bsd.rd as /bsd

  $interfaces = hiera_hash("interface")

  $filepath = "$netboot::site_mirror/OpenBSD/$version/alpha"

  file{"$inetd::tftpd::tftproot/netboot.obsd.$version.alpha":
    ensure => present,
    source => "$filepath/netboot",
  }

  file{"$netboot::jumpstart_common::mount/obsd.$version.alpha":
    ensure => directory,
  }
  ->
  file{"$netboot::jumpstart_common::mount/obsd.$version.alpha/bsd":
    ensure => present,
    source => "$filepath/bsd.rd",
  }

  define obsd_alpha_tftplink(
    $host = $title,
    $root,
  ) {
    $interfaces = $netboot::obsd_alpha::interfaces
    $ip = $interfaces[$host]['ip']
    netboot::tftplink{"$ip": source => "netboot.obsd.$netboot::obsd_alpha::version.alpha" }
    bootparamd::line{"$host": content => "$host root=$root\n"}
  }

  if $hosts {
    obsd_alpha_tftplink{$hosts: root => "${::hostname}:${netboot::jumpstart_common::mount}/obsd.${version}.alpha/" }
  }
}
