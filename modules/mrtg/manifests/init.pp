class mrtg {
  $packages = hiera('mrtg::packages')
  $dir = hiera('mrtg::datadir')

  package { $packages: ensure => installed }
}
