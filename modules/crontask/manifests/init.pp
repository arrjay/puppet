class crontask (
) {
  $dir = hiera('crontask::dir')

  file {$dir:
    ensure => directory,
    mode   => 0755,
    owner  => root,
    group  => root,
  }
}
