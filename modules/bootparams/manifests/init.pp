class bootparams(
) {
  include portmap

  case $::osfamily {
    'RedHat': {
      if versioncmp($::operatingsystemmajrelease, '6') >= 0 {
        include rpmrepo::arrjay
        $packages = ['bootparamd']
        $service = 'bootparamd'
        $override_unit_file = '/etc/systemd/system/bootparamd.service.d/router.conf'
      }
    }
  }

  if $override_unit_file {
    # oh yes, this is undoubtedly grubby. don't...care.
    $unitdir = inline_template('<%= d = String.new(str=@override_unit_file) ; f = d[/([^\/]+)$/]; d.slice!(f) ; d -%>')
    file{$unitdir:
      ensure => directory,
      mode   => '0755',
    }
    file{$override_unit_file:
      ensure  => present,
      content => "[Service]\nExecStart=\nExecStart=/usr/sbin/rpc.bootparamd -s $::dhcpd::gateway",
      notify  => Service[$service],
    }
  }

  ensure_packages($packages)

  service{$service: enable => true, ensure => running}
}
