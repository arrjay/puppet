class mrtg {
  $packages = hiera('mrtg::packages')
  $dir = hiera('mrtg::datadir')

  package { $packages: ensure => installed }

  # FreeBSD systems actually need the mrtg datadir to exist
  case $::operatingsystem {
    'FreeBSD': {
      file{$dir:
        ensure => directory,
        owner  => root,
        group  => 0,
        mode   => 0755,
      }
    }
  }
}
