class pkgenv (
  $packages = hiera('pkgenv::packages'),
) {
  package{$packages: ensure => installed}
}
