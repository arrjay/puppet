define netboot::work::gunzip(
  $file = $title
) {
  $dfile = regsubst($file,'^(.*).gz$','\1')
  exec{"gunzip $::netboot::work::scratchdir/$file":
    command     => "zcat $::netboot::work::scratchdir/$file > $dfile",
    cwd         => "$::tftp::root",
    refreshonly => true,
    subscribe   => File["$::netboot::work::scratchdir/$file"],
  }
}
