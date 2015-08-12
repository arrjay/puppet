class netboot::ip2x_common (
  $fxarcs_src = hiera('netboot::uri::fxarcs')
) {
  include tftp
  require curl

  curl::fetch { "fx.ARCS":
    source      => $fxarcs_src,
    destination => "${::tftp::root}/fx.ARCS",
  }

  file { "${::tftp::root}/fx.ARCS":
    require => Curl::Fetch["fx.ARCS"],
  }
}
