class fileserver (
  $packages = hiera('fileserver::packages')
  #$services = hiera('fileserver::services')
) {
  # this is just stuff handy for any fileserver :)
  package{$packages: ensure => installed}
}
