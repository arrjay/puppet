class fileserver::netatalk(
) {
  case $::operatingsystem {
    'FreeBSD': {
      # we need krb5 UAM support, so...
      require freebsd::portupgrade
      # build prereqs via packages, *then* build it.
      package{[
        "converters/libiconv",
        "databases/db46",
        "devel/dbus-glib",
        "devel/gmake",
        "devel/libevent2",
        "devel/libtool",
        "devel/pkgconf",
        "lang/perl5.14",
        "net/avahi-app",
        "security/libgcrypt",
      ]: ensure => installed } ~> package{"net/netatalk3": ensure => installed, provider => 'portupgrade' }
    }
  }
}
