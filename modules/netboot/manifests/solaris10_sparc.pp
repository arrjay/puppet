class netboot::solaris10_sparc(
  $rsync_source = hiera('netboot::rsync::solaris10'),
  $sun4u_hosts = hiera('netboot::solaris10::sun4u_hosts',undef),
) {
  # needed for downcase, of all things.
  include stdlib

  # pick up dhcpd/ifgen
  require dhcpd::ifgen

  # pick up definitions appropriate for all jumpstart OSes
  include netboot::jumpstart_common

  # pick up the network parameters, we need them to hack the installer files :)
  $netinfo = hiera_hash('network')
  $hexmask = downcase(ip2hex($netinfo['netmask']))

  # The Sun Blade 1000 system supports Solaris 8, software release 10/00 to Solaris 11 Express
  # The Sun Blade 150 workstation supports Solaris 8, software release 2/02 to Solaris 11 Express
  # I have Solaris 10 1/13 (Update 11), so I'm assuming that.

  # go get the software
  netboot::jumpstart_common::sync{'sol10': source => $rsync_source}

  # hey, sol10 no longer does the crazy NFS root!
  ->
    # finally, get the bootloaders for TFTP
    file{"$inetd::tftpd::tftproot/inetboot.sol10.sun4u":
      ensure => present,
      source => "$netboot::jumpstart_common::mount/sol10/Solaris_10/Tools/Boot/platform/sun4u/inetboot",
    }
    #->
    # http://malpaso.ru/solaris-jumpstart-bug/ - hack sol8/Solaris_8/Tools/Boot/sbin/rcS to wire out netmask in
    # actually, my particular problem turned out to be bootparamd returning idiocy.
    #exec{"hacking solaris8 startup script to use netmask":
    #  command => "/usr/bin/sed -e 's/ifconfig \$i up/ifconfig \$i netmask $hexmask up/' -i .bak $netboot::jumpstart_common::mount/sol8/Solaris_8/Tools/Boot/sbin/rcS",
    #  unless => "/usr/bin/grep -q 'netmask $hexmask' $netboot::jumpstart_common::mount/sol8/Solaris_8/Tools/Boot/sbin/rcS",
    #}

  define solaris10_sun4u_host(
    $host = $title,
  ) {
    $interfaces = $netboot::jumpstart_common::interfaces
    $ip = $interfaces[$host]['ip']
    netboot::tftplink{"$ip": source => "inetboot.sol10.sun4u"}
  }

  if $sun4u_hosts {
    notice("we only set up the tftp link - specify host params in hieradata!")
    solaris10_sun4u_host{$sun4u_hosts: }
  }
}
