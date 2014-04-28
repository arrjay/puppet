class netboot::alphapc_164lx_fw (
  $srm_rom = hiera('netboot::uri::alphapc_164lx_srmfw'),
  $fwupdate_exe = hiera('netboot::uri::alphapc_164lx_fwupdate'),
  $ab_rom_zip = hiera('netboot::uri::alphapc_164lx_alphabios_zip'),
) {
  include inetd::tftpd

  $lxroot="$inetd::tftpd::tftproot/164lx"

  file{$lxroot:
    ensure => directory,
  }
  ->
  exec{"get lx164srm.rom":
    command => "/usr/bin/fetch $srm_rom",
    cwd => $lxroot,
    creates => "$lxroot/lx164srm.rom",
  }
  ->
  exec{"get lx164/fwupdate.exe":
    command => "/usr/bin/fetch $fwupdate_exe",
    cwd => $lxroot,
    creates => "$lxroot/fwupdate.exe",
  }
  ->
  exec{"get lx164alphabios zip":
    command => "/usr/bin/fetch $ab_rom_zip",
    cwd => "/tmp",
    unless => "/bin/test -f $lxroot/lx164nt.rom",
  }
  ~>
  exec{"unpack abLXSXv570.zip":
    command => "/usr/bin/tar xf abLXSXv570.zip LX164NT.ROM",
    cwd => "/tmp",
    refreshonly => true,
  }
  ~>
  exec{"move LX164NT.ROM to $lxroot":
    command => "/bin/mv /tmp/LX164NT.ROM $lxroot/lx164nt.rom",
    refreshonly => true,
  }
}
