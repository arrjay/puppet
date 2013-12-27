class sudo (
  $packages = hiera('sudo::packages')
) {
  package{$packages: ensure => installed}
}
