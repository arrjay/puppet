class java {
  case $::operatingsystem {
    'FreeBSD': {
      package { "java/openjdk6-jre": ensure => installed }
      include java::freebsd
    }
  }
}
