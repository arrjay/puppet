# Configure TFTP
class tftp::config {

  case $::tftp::params::daemon {
    default: { } # not needed for daemon-mode
    false: {
      include ::xinetd

      xinetd::service { 'tftp':
        port        => '69',
        server      => '/usr/sbin/in.tftpd',
        # note, if using selinux on el7, you'll want to run "setsebool -P nis_enabled=on"
        server_args => "-v -s ${::tftp::root} -m /etc/tftpd.map -R 2048:32767",
        socket_type => 'dgram',
        protocol    => 'udp',
        cps         => '100 2',
        flags       => 'IPv4',
        per_source  => '11',
      }

      file {'/etc/tftpd.map':
        content => template('tftp/tftpd.map'),
        mode    => '0644',
        notify  => Class['xinetd'],
      }

      file { $::tftp::root:
        ensure => directory,
        notify => Class['xinetd'],
      }
    }
  }
}
