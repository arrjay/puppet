class netboot::irix65 (
  $hosts = hiera('netboot::irix65_hosts',undef),
) {
  # tftp, fx partitioner
  include ip2x_common

  # filesystem, user account, shell, sync define
  include irix_common

  # ifgen for dhcpd
  #require dhcpd
  #include dhcpd::ifgen

  $os = 'irix/6.5'
  $cc = 'mipspro'
  $nfs = 'onc3_nfs'
  $snmp = 'snmp'

  # we handle IRIX 6.5.1 (Old Indigo2), 6.5.22 (Indigo2), 6.5.29 (O2/Octane)
  $components = [ "$os/S100_6.5.1_Installation_Tools_Overlays_1",
                  "$os/S100_IRIX6.5.22_1of3",
                  "$os/S100_6.5.29_Installation_Tools_Overlays_1",
                  "$os/S101_6.5.1_Overlays_2",
                  "$os/S101_IRIX6.5.22_2of3",
                  "$os/S101_6.5.29_Overlays_2",
                  "$os/S102_IRIX6.5.22_3of3",
                  "$os/S102_6.5.29_Overlays_3",
                  "$os/S200_6.5_Foundation_1",
                  "$os/S201_6.5_Foundation_2 (2004)",
                  "$os/S220_6.5_Applications_2004_08",	# from 6.5.25 (really)
                  "$os/S220_6.5_Applications_2006_02",	# from 6.5.29
                  "$os/S300_6.5_Development_Libraries (2004)",
                  "$os/S700_6.5_Complimentary_Applications_2004_08",
                  "$os/S700_6.5_Complimentary_Applications_2006_02",
                  "$os/S700_6.5_Development_Foundation (2004)",
                  "$os/S900_6.5.12_General_and_Platform_Demos_1",
                  "$os/S900_6.5.12_General_and_Platform_Demos_2",
                  #"$cc/S700_6.[2-5]_MIPSpro_C_Compiler_7.2.1",	# handled by irix62!
                  #"$nfs/S700_6.[2-5]_ONC3_NFS_v3",		# handled by irix62!
                  "$snmp/S700_6.5_SNMP_Access_to_HP-UX_MIB_1.1.3", ]

  netboot::irix_common::sync{$components: }

  if $hosts {
    netboot::irix_common::grant_rsh{$hosts: }
  #  Dhcpd::Ifgen::Dhcp_host <| title == $hosts |> {
  #    bootfile => "$netboot::irix_common::mount/irix/6.2",
  #  }
  }

  file{"$netboot::irix_common::mount/6.5.1":
    ensure => directory,
  }
  ->
  file{"$netboot::irix_common::mount/6.5.1/sashARCS":
    ensure => link,
    target => "../irix/6.5/S100_6.5.1_Installation_Tools_Overlays_1/.dvh/sashARCS",
  }
  ->
  file{"$netboot::irix_common::mount/6.5.1/sa":
    ensure => link,
    target => "../irix/6.5/S100_6.5.1_Installation_Tools_Overlays_1/dist/sa",
  }
  ->
  file{"$netboot::irix_common::mount/6.5.1/miniroot":
    ensure => link,
    target => "../irix/6.5/S100_6.5.1_Installation_Tools_Overlays_1/dist/miniroot",
  }

  file{"$netboot::irix_common::mount/6.5.22":
       # "$netboot::irix_common::mount/6.5.29",]:
    ensure => directory,
  }
  ->
  file{"$netboot::irix_common::mount/6.5.22/sashARCS":
    ensure => link,
    # recycle 6.5.1's sashARCS here
    target => "../irix/6.5/S100_6.5.1_Installation_Tools_Overlays_1/.dvh/sashARCS",
  }
  ->
  file{"$netboot::irix_common::mount/6.5.22/sa":
    ensure => link,
    target => "../irix/6.5/S100_IRIX6.5.22_1of3/sa",
  }
  ->
  file{"$netboot::irix_common::mount/6.5.22/miniroot":
    ensure => link,
    target => "../irix/6.5/S100_IRIX6.5.22_1of3/miniroot",
  }

  # retrieve/extract patches
  define getpatch(
    $dirname = $title,
    $tarfile,
  ) {
    exec{"fetch $dirname package ($tarfile)":
      command => "/usr/bin/fetch $netboot::irix_common::patch_mirror/6.5/$tarfile -o $netboot::irix_common::mount/patches/$tarfile",
      creates => "$netboot::irix_common::mount/patches/$tarfile",
    }
    ->
    file{"$netboot::irix_common::mount/patches/$dirname":
      ensure => directory,
    }
    ~>
    exec{"extract $tarfile":
      command => "/usr/bin/tar xf $netboot::irix_common::mount/patches/$tarfile -C $netboot::irix_common::mount/patches/$dirname",
      refreshonly => true,
    }
  }

  getpatch{'patchSG0005086': tarfile => 'patchSG0005086.tardist' }

}
