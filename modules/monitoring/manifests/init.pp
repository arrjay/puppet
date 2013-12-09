class monitoring (
) {
  $packages = hiera('monitoring::packages',undef)
  $services = hiera('monitoring::services',undef)

  if $packages {
    package{$packages: ensure => installed}
  }
  if $services {
    service{$services: enable => true, ensure => running }
  }
}
