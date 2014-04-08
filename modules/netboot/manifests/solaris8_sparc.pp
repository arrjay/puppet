class netboot::solaris8_sparc(
  $rsync_source = hiera('netboot::rsync::solaris8'),
  $sun4m_hosts = hiera('netboot::solaris8::sun4m_hosts',undef),
  $sun4u_hosts = hiera('netboot::solaris8::sun4u_hosts',undef),
) {
  # needed for downcase, of all things.
  include stdlib

  # pick up definitions appropriate for all jumpstart OSes
  include netboot::jumpstart_common

  # pick up the network parameters, we need them to hack the installer files :)
  $netinfo = hiera_hash('network')
  $hexmask = downcase(ip2hex($netinfo['netmask']))

  # The Spartscation LX is older than dirt, supports SunOS 4.1.3c onwards or Solaris 2.3 Edition II to Solaris 9
  # The Sun Blade 1000 system supports Solaris 8, software release 10/00 to Solaris 11 Express
  # The Sun Blade 150 workstation supports Solaris 8, software release 2/02 to Solaris 11 Express
  # I have Solaris 8 2/04 (Update 7 HW4), so I'm assuming that.

  # go get the software
  netboot::jumpstart_common::sync{'sol8': source => $rsync_source}
  ->
  # these are files that need permissions reset (due to being granted all read access from rsync server)
  # I wanted to do this as an anonymous code block, but puppet can't do that! so, chaining arrows for all.
    file{["$netboot::jumpstart_common::mount/sol8/Solaris_8/Tools/Boot/etc/security/audit_control",
          "$netboot::jumpstart_common::mount/sol8/Solaris_8/Tools/Boot/etc/security/audit_user"]:
             mode => 0640,
             owner => root,
             group => 0,
    }
    ->
    file{["$netboot::jumpstart_common::mount/sol8/Solaris_8/Tools/Boot/etc/security/audit_warn",
          "$netboot::jumpstart_common::mount/sol8/Solaris_8/Tools/Boot/etc/security/bsmconv",
          "$netboot::jumpstart_common::mount/sol8/Solaris_8/Tools/Boot/etc/security/bsmunconv"]:
             mode => 0740,
             owner => root,
             group => 0,
    }
    ->
    file{["$netboot::jumpstart_common::mount/sol8/Solaris_8/Tools/Boot/.tmp_proto/root/var/log/authlog",
          "$netboot::jumpstart_common::mount/sol8/Solaris_8/Tools/Boot/etc/security/dev/audio",
          "$netboot::jumpstart_common::mount/sol8/Solaris_8/Tools/Boot/etc/security/dev/fd0",
          "$netboot::jumpstart_common::mount/sol8/Solaris_8/Tools/Boot/etc/security/dev/sr0",
          "$netboot::jumpstart_common::mount/sol8/Solaris_8/Tools/Boot/etc/security/dev/st0",
          "$netboot::jumpstart_common::mount/sol8/Solaris_8/Tools/Boot/etc/security/dev/st1",
          "$netboot::jumpstart_common::mount/sol8/Solaris_8/Tools/Boot/tmp/root/var/adm/aculog",
          "$netboot::jumpstart_common::mount/sol8/Solaris_8/Tools/Boot/tmp/root/var/log/authlog"]:
             mode => 0600,
             owner => root,
             group => 0,
    }
    ->
    file{["$netboot::jumpstart_common::mount/sol8/Solaris_8/Tools/Boot/etc/security/lib/audio_clean",
          "$netboot::jumpstart_common::mount/sol8/Solaris_8/Tools/Boot/etc/security/lib/fd_clean",
          "$netboot::jumpstart_common::mount/sol8/Solaris_8/Tools/Boot/etc/security/lib/sr_clean",
          "$netboot::jumpstart_common::mount/sol8/Solaris_8/Tools/Boot/etc/security/lib/st_clean"]:
             mode => 0751,
             owner => root,
             group => 0,
    }
    ->
    file{"$netboot::jumpstart_common::mount/sol8/Solaris_8/Tools/Boot/platform/SUNW,Ultra-Enterprise-10000/lib/cvcd":
             mode => 0700,
             owner => root,
             group => 0,
    }
    ->
    file{["$netboot::jumpstart_common::mount/sol8/Solaris_8/Tools/Boot/usr/bin/admintool",
          "$netboot::jumpstart_common::mount/sol8/Solaris_8/Tools/Boot/usr/bin/mail",
          "$netboot::jumpstart_common::mount/sol8/Solaris_8/Tools/Boot/usr/bin/mailx",
          "$netboot::jumpstart_common::mount/sol8/Solaris_8/Tools/Boot/usr/bin/tip",
          "$netboot::jumpstart_common::mount/sol8/Solaris_8/Tools/Boot/usr/lib/lp/bin/netpr"]:
             mode => 0511,
             owner => root,
             group => 0,
    }
    ->
    file{"$netboot::jumpstart_common::mount/sol8/Solaris_8/Tools/Boot/usr/bin/logins":
             mode => 0750,
             owner => root,
             group => 0,
    }
    ->
    file{"$netboot::jumpstart_common::mount/sol8/Solaris_8/Tools/Boot/usr/lib/pt_chmod":
             mode => 0111,
             owner => root,
             group => 0,
    }
    ->
    file{["$netboot::jumpstart_common::mount/sol8/Solaris_8/Tools/Boot/usr/sbin/sysidconfig",
          "$netboot::jumpstart_common::mount/sol8/Solaris_8/Tools/Boot/usr/sbin/sysidget",
          "$netboot::jumpstart_common::mount/sol8/Solaris_8/Tools/Boot/usr/sbin/sysidkrb5",
          "$netboot::jumpstart_common::mount/sol8/Solaris_8/Tools/Boot/usr/sbin/sysidnet",
          "$netboot::jumpstart_common::mount/sol8/Solaris_8/Tools/Boot/usr/sbin/sysidns",
          "$netboot::jumpstart_common::mount/sol8/Solaris_8/Tools/Boot/usr/sbin/sysidput",
          "$netboot::jumpstart_common::mount/sol8/Solaris_8/Tools/Boot/usr/sbin/sysidroot",
          "$netboot::jumpstart_common::mount/sol8/Solaris_8/Tools/Boot/usr/sbin/sysidsys"]:
             mode => 0711,
             owner => root,
             group => 0,
    }
    ->
    # finally, get the bootloaders for TFTP
    file{"$inetd::tftpd::tftproot/inetboot.sol8.sun4m":
      ensure => present,
      source => "$netboot::jumpstart_common::mount/sol8/Solaris_8/Tools/Boot/usr/platform/sun4m/lib/fs/nfs/inetboot",
    }
    #->
    # http://malpaso.ru/solaris-jumpstart-bug/ - hack sol8/Solaris_8/Tools/Boot/sbin/rcS to wire out netmask in
    # actually, my particular problem turned out to be bootparamd returning idiocy.
    #exec{"hacking solaris8 startup script to use netmask":
    #  command => "/usr/bin/sed -e 's/ifconfig \$i up/ifconfig \$i netmask $hexmask up/' -i .bak $netboot::jumpstart_common::mount/sol8/Solaris_8/Tools/Boot/sbin/rcS",
    #  unless => "/usr/bin/grep -q 'netmask $hexmask' $netboot::jumpstart_common::mount/sol8/Solaris_8/Tools/Boot/sbin/rcS",
    #}

  define solaris8_sun4m_host(
    $host = $title,
  ) {
    $interfaces = $netboot::jumpstart_common::interfaces
    $ip = $interfaces[$host]['ip']
    netboot::tftplink{"$ip": source => "inetboot.sol8.sun4m", suffix => "SUN4M"}
    bootparamd::line{"$host": content => "$host root=$::hostname:$netboot::jumpstart_common::mount/sol8/Solaris_8/Tools/Boot install=$::hostname:$netboot::jumpstart_common::mount/sol8 boottype=:in\n"}
  }

  if $sun4m_hosts {
    solaris8_sun4m_host{$sun4m_hosts: }
  }
}
