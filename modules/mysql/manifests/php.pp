# install php mysql module
class mysql::php (
) {
  # configure
  case $::osfamily {
    'RedHat': {
      $packages = [ "php-mysql" ]
    }
  }

  package {$packages: ensure => present }
}
