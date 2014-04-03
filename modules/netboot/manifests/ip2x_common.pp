class netboot::ip2x_common (
  $fxarcs_src = hiera('netboot::uri::fxarcs'),
) {
  include inetd::tftpd
  # SGI IP22 machines often try to treat UDP port ranges as a signed integer, so...
  class{"tuning::freebsd": portrange_last => '32767'}

  # Go get the IRIX partitioner.
  exec{"get fx.ARCS":
    command => "/usr/bin/fetch $fxarcs_src",
    cwd => $inetd::tftpd::tftproot,
    creates => "$inetd::tftpd::tftproot/fx.ARCS",
  }
}
