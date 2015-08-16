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
#      notify => Exec["zcat ${::netboot::work::scratchdir}/netbsd-INSTALL32${kfx} > netbsd-INSTALL32${kfx}"],
    }
    netboot::work::gunzip{"netbsd-INSTALL32${kfx}":}
  }

}
