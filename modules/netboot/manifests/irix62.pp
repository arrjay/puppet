class netboot::irix62 (
  $hosts = hiera('netboot::irix62_hosts',undef),
) {
  # tftp, fx partitioner
  include ip2x_common

  # filesystem, user account, shell, sync define
  include irix_common

  # ifgen for dhcpd
  #require dhcpd
  #include dhcpd::ifgen

  $os = 'irix/6.2'
  $cc = 'mipspro'
  $nfs = 'onc3_nfs'
  $snmp = 'snmp'

  $components = [ "$os/S200_6.2_IRIX_1", "$os/S201_6.2_IRIX_2",
                  "$os/S300_6.[2-3]_IRIS_Development_Option_7.0.1",
                  "$os/S700_6.2_Applications_1996_08",
                  "$os/S700_Desktop_Special_Edition_1.1",
                  "$os/S700_Visual_Magic_Tools_1.0",
                  "$os/S999_6.2_Patches_for_IRIX_with_Indigo2_1996_08",
                  "$os/S999_6.2_Required_Patch_Sets",
                  "$os/irix-6.2-development-libraries",
                  "$os/irix-development-foundation-1.2-for-irix-6.2",
                  "$cc/S700_6.[2-3]_MIPSpro_C++_7.0.1",
                  "$cc/S700_6.[2-5]_MIPSpro_C_Compiler_7.2.1",
                  "$nfs/S700_6.[2-5]_ONC3_NFS_v3",
                  "$snmp/S700_6.[2-5]_SNMP_Access_to_HP-UX_MIB_1.1.2", ]

  netboot::irix_common::sync{$components: }

  if $hosts {
    netboot::irix_common::grant_rsh{$hosts: }
  #  Dhcpd::Ifgen::Dhcp_host <| title == $hosts |> {
  #    bootfile => "$netboot::irix_common::mount/irix/6.2",
  #  }
  }

  file{"$netboot::irix_common::mount/6.2":
    ensure => directory,
  }
  ->
  file{"$netboot::irix_common::mount/6.2/sashARCS":
    ensure => link,
    target => "../irix/6.2/S200_6.2_IRIX_1/stand/sashARCS",
  }
  file{"$netboot::irix_common::mount/6.2/sa":
    ensure => link,
    target => "../irix/6.2/S200_6.2_IRIX_1/dist/sa",
  }
  file{"$netboot::irix_common::mount/6.2/miniroot":
    ensure => link,
    target => "../irix/6.2/S200_6.2_IRIX_1/dist/miniroot",
  }

  # irix 6.2 dist links are handled outside of this, though
  include netboot::irix62::links

}
