#
class portmap::install {

  if $::portmap::manage_package {
    ensure_packages($::portmap::package_name)
  }
}
