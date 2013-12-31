class fileserver::netatalk(
) {
  case $::operatingsystem {
    'FreeBSD': {
      $atalk_pkg = "net/netatalk3"
      $afp_conf  = "/usr/local/etc/afp.conf"
      # we need krb5 UAM support, so...
      require freebsd::portupgrade
      # install prereqs via packages, *then* build it.
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
      ]: ensure => installed } ~> package{$atalk_pkg: ensure => installed, provider => 'portupgrade' }
      # we need avahi for netatalk to properly announce
      require avahi
    }
  }

  file{"$afp_conf":
    owner   => root,
    group   => 0,
    mode    => 0644,
    ensure  => present,
    content => template("fileserver/afp.conf.erb"),
  }
}
