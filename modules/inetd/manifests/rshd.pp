class inetd::rshd (
  $logging	= hiera('inetd::rshd::logging',true),
  $hosts_equiv  = hiera('inetd::rshd::hosts_equiv'),
) {
  require inetd
  # some day, I'll figure out why calling inetd's restarter directly sucks
  exec { "restart inetd: rshd changes":
    refreshonly => true,
    command     => "/usr/sbin/service $inetd::svc restart",
  }

  # build up the tftp string for inetd regardless of OS. Only tested on FreeBSD, though :)
  $basic_rshd = 'shell stream tcp nowait root /usr/libexec/rshd rshd'
  if $logging {
    $log_flags = " -L"
  }
  $rshd_string = "${basic_rshd}${log_flags}"

  case $::operatingsystem {
    'FreeBSD': {
      # augeas lens is some kind of broken, we only check if we can change it
      augeas { "inetd.conf: rshd basics":
        changes => [
          "set /files/etc/inetd.conf/service[ . = 'shell' ]/socket stream",
          "set /files/etc/inetd.conf/service[ . = 'shell' ]/protocol tcp",
          "set /files/etc/inetd.conf/service[ . = 'shell' ]/wait nowait",
          "set /files/etc/inetd.conf/service[ . = 'shell' ]/user root",
          "set /files/etc/inetd.conf/service[ . = 'shell' ]/command /usr/libexec/rshd",
          "set /files/etc/inetd.conf/service[ . = 'shell' ]/arguments/1 rshd",
        ],
        onlyif => "match /files/etc/inetd.conf/service[ . = 'shell' ] size != 0",
        notify => Exec["restart inetd: rshd changes"],
      }
      # we provide cases for off->on, and on->off.
      if $logging == true {
        augeas { "inetd.conf: enable rshd logging":
          changes => [
            "ins 03 after /files/etc/inetd.conf/service[ . = 'shell' ]/arguments/*[ . = 'rshd' ]",
            "set /files/etc/inetd.conf/service[ . = 'shell' ]/arguments/03 '-L'",
          ],
          onlyif => "match /files/etc/inetd.conf/service[ . = 'shell' ]/arguments/*[ . = '-L' ] size == 0",
          require => Augeas["inetd.conf: rshd basics"],
          notify => Exec["restart inetd: rshd changes"],
        }
      } else {
        augeas { "inetd.conf: disable rshd logging":
          changes => [
            "rm /files/etc/inetd.conf/service[ . = 'shell' ]/arguments/*[ . = '-L' ]",
          ],
          onlyif => "match /files/etc/inetd.conf/service[ . = 'tftp' ]/arguments/*[ . = '-L' ] size != 0",
          require => Augeas["inetd.conf: rshd basics"],
          notify => Exec["restart inetd: rshd changes"],
        }
      }
      # Handle the case when we don't have tftpd set up at all
      exec { "inetd.conf: add rshd":
        command => "/bin/echo '${rshd_string}' >> '/etc/inetd.conf'",
        unless  => "/usr/bin/grep -q '^shell' /etc/inetd.conf",
        notify  => Exec["restart inetd: rshd changes"],
      }
    }
  }

  concat{$hosts_equiv:
    owner => root,
    group => 0,
    mode  => 0644,
    force => true,
  }

  define hosts_equiv(
    $hostname = $title,
  ) {
    concat::fragment{"rshd: hosts.equiv for $hostname":
      target => $inetd::rshd::hosts_equiv,
      content => "$hostname\n",
    }
  }
}
