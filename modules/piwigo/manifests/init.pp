class piwigo (
  $packages = hiera('piwigo::packages')
) {
  # install a php stack first
  include phpstack

  package{$packages: ensure => installed}
}
