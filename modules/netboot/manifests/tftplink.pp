define netboot::tftplink(
  $suffix = undef,
  $source,
  $ip = $title,
) {
  include tftp

  $ip2hex = ip2hex($ip)
  file{ "${::tftp::root}/${ip2hex}":
    ensure => link,
    target => "./${source}",
  }
  if $suffix {
    file{ "${::tftp::root}/${ip2hex}.${suffix}":
      ensure => link,
      target => "./${source}",
    }
  }
}
