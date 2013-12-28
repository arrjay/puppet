class fileserver (
  $packages = hiera('fileserver::packages')
  #$services = hiera('fileserver::services')
) {
  # for consistency reasons, fileservers get automount by default :)
  include automount
  # this is just stuff handy for any fileserver :)
  package{$packages: ensure => installed}
}
