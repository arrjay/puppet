class nameserver::ifgen (
  $zonedir = '/var/named/chroot/var/named'
) {
  # this only handles creating the j.hack zone files and such.
  # you will need to tinker with nameserver view params to load
  # the result yourself.
  require nameserver
  file { "$zonedir/j.hack":
    content => template('nameserver/ifgen_forward.erb')
  }
  ['j.hack', 'chaos.produxi.net'].each |$revpoint| {
    file { "$zonedir/252.100.10-$revpoint":
      content => template('nameserver/ifgen_reverse.erb')
    }
  }
}
