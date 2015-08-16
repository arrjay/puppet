class netboot::work (
  $scratchdir = "$::tftp::root/.work",
) {
  # this just hold a staging dir to keep compressed binaries. stupid gzip.
  file { $scratchdir:
    ensure => directory,
    mode   => '0700',
  }

}
