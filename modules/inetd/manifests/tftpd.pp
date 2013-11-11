class inetd::tftpd {
  require inetd

  $tftproot = $inetd::inetd_cfg['tftpd']['rootdir']

  # build up the tftp string for inetd regardless of OS. Only tested on FreeBSD, though :)
  $basic_tftpd = 'tftp dgram udp wait root /usr/libexec/tftpd tftpd'
  if $inetd::inetd_cfg['tftpd']['rootdir'] {
    $root_flags = " -s $inetd::inetd_cfg['tftpd']['rootdir']"
  }
  if $inetd::inetd_cfg['tftpd']['logging'] == 'yes' {
    $log_flags = " -l"
  }
  if $inetd::inetd_cfg['tftpd']['rfc2347'] == 'no' {
    $old_flags = " -o"
  }
  $tftpd_string = "${basic_tftpd}${old_flags}${log_flags}${root_flags}"

  case $::operatingsystem {
    'FreeBSD': {
      # augeas lens is some kind of broken, we only check if we can change it
      augeas { "inetd.conf: tftpd basics":
        changes => [
          "set /files/etc/inetd.conf/service[ . = 'tftp' ]/socket dgram",
          "set /files/etc/inetd.conf/service[ . = 'tftp' ]/protocol udp",
          "set /files/etc/inetd.conf/service[ . = 'tftp' ]/wait wait",
          "set /files/etc/inetd.conf/service[ . = 'tftp' ]/user root",
          "set /files/etc/inetd.conf/service[ . = 'tftp' ]/command /usr/libexec/tftpd",
          "set /files/etc/inetd.conf/service[ . = 'tftp' ]/arguments/1 tftpd",
        ],
        onlyif => "match /files/etc/inetd.conf/service[ . = 'tftp' ] size != 0",
      }
      # owwwww. if we fail to match root, delete the -s flag, delete any arguments starting with /
      # 01, 02 are numeric labels - gotta fit the [:digit:] realm, but have no other importance
      #  (in fact, the next run will have them discarded)
      if $inetd::inetd_cfg['tftpd']['rootdir'] {
        augeas { "inetd.conf: tftpd root":
          changes => [
            "rm /files/etc/inetd.conf/service[ . = 'tftp' ]/arguments/*[ . = '-s' ]",
            "rm /files/etc/inetd.conf/service[ . = 'tftp' ]/arguments/*[ . =~ regexp('/.*') ]",
            "set /files/etc/inetd.conf/service[ . = 'tftp' ]/arguments[last()]/01 '-s'",
            "set /files/etc/inetd.conf/service[ . = 'tftp' ]/arguments[last()]/02 $tftproot",
          ],
          onlyif => "get /files/etc/inetd.conf/service[ . = 'tftp' ]/arguments/*[preceding-sibling::*[1][. = '-s']] != $tftproot",
          require => Augeas["inetd.conf: tftpd basics"],
        }
      }
      # if we need to disable rfc2347 (only possible on *BSD tftp?), do it after we get a successful tftp service to modify.
      # we provide cases for off->on, and on->off.
      if $inetd::inetd_cfg['tftpd']['rfc2347'] == false {
        augeas { "inetd.conf: disable tftpd rfc2347":
          changes => [
            "ins 03 after /files/etc/inetd.conf/service[ . = 'tftp' ]/arguments/*[ . = 'tftpd' ]",
            "set /files/etc/inetd.conf/service[ . = 'tftp' ]/arguments/03 '-o'",
          ],
          onlyif => "match /files/etc/inetd.conf/service[ . = 'tftp' ]/arguments/*[ . = '-o' ] size == 0",
          require => Augeas["inetd.conf: tftpd basics"],
        }
      } else {
        augeas { "inetd.conf: enable tftpd rfc2347":
          changes => [
            "rm /files/etc/inetd.conf/service[ . = 'tftp' ]/arguments/*[ . = '-o' ]",
          ],
          onlyif => "match /files/etc/inetd.conf/service[ . = 'tftp' ]/arguments/*[ . = '-o' ] size != 0",
          require => Augeas["inetd.conf: tftpd basics"],
        }
      }
      # Handle the case when we don't have tftpd set up at all
      exec { "inetd.conf: add tftpd":
        command => "/bin/echo '${tftpd_string}' >> '/etc/inetd.conf'",
        unless  => "/usr/bin/grep -q '^tftp' /etc/inetd.conf",
      }
    }
  }
}
