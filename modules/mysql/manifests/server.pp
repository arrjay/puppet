# install a mysql server stack
class mysql::server (
) {
  # config
  case $::osfamily {
    'RedHat' : {
      # rh7 calls everything mariadb now
      if $::operatingsystemmajrelease >= 7 {
        $packages = [ "mariadb-server" ]
        $services = [ "mariadb" ]
      } else {
        $packages = [ "mysql-server" ]
        $services = [ "mysqld" ]
      }
    }
  }

  # do
  package { $packages: ensure => installed }
  service { $services: enable => true, ensure => running }
}
