class netboot::netbsd::ip2x (
  $version = hiera('netboot::netbsd::ip2x::version'),
) {
  include mirror2::netbsd::sgimips
  include netboot::ip2x_common
  include netboot::work

  ['_IP2x.gz','_IP2x.ecoff.gz'].each |$kfx| {
    file{"${::netboot::work::scratchdir}/netbsd-INSTALL32${kfx}":
      ensure => present,
      source => "$::mirror2::dest/NetBSD/NetBSD-$version/sgimips/binary/kernel/netbsd-INSTALL32${kfx}",
    }
    netboot::work::gunzip{"netbsd-INSTALL32${kfx}":}
  }

  exec{"tar --extract --strip-components=3 --file=${::mirror2::dest}/NetBSD/NetBSD-$version/sgimips/binary/sets/base.tgz ./usr/mdec/ip2xboot":
    command     => "tar --extract --strip-components=3 --file=${::mirror2::dest}/NetBSD/NetBSD-$version/sgimips/binary/sets/base.tgz ./usr/mdec/ip2xboot",
    cwd         => "$::tftp::root",
    refreshonly => true,
    subscribe   => [File["${::netboot::work::scratchdir}/netbsd-INSTALL32_IP2x.gz"],File["${::netboot::work::scratchdir}/netbsd-INSTALL32_IP2x.gz"]],
  }
}
