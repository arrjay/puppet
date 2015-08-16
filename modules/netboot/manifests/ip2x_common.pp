class netboot::ip2x_common (
  $fxarcs_src   = hiera('netboot::uri::fxarcs'),
  $sasharcs_src = hiera('netboot::uri::sasharcs'),
) {
  include tftp
  require curl

  curl::fetch { "fx.ARCS":
    source      => $fxarcs_src,
    destination => "${::tftp::root}/fx.ARCS",
  }

  curl::fetch { "sashARCS":
    source      => $sasharcs_src,
    destination => "${::tftp::root}/sashARCS",
  }

  file { "${::tftp::root}/fx.ARCS":
    require => Curl::Fetch["fx.ARCS"],
  }

  file { "${::tftp::root}/sashARCS":
    require => Curl::Fetch["sashARCS"],
  }
}
