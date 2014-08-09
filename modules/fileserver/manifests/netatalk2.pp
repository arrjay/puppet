class fileserver::netatalk2(
  $homeserver = hiera('fileserver::netatalk_homeserver',false),
  $homepath   = hiera('fileserver::netatalk_homepath',undef),
) {
  # die if you called the 'default' netatalk module
  if defined(Class['fileserver::netatalk']) {
    fail("Can not run two netatalk servers at once")
  }
  # we call ldapclient directly so we can fish binding variables out of it. we need those.
  require ldapclient
  # we call krbclient because we might just talk that
  require krbclient
  $ldapdn     = $ldapclient::binddn
  $ldappw     = $ldapclient::bindpw
  $userbase   = $ldapclient::nss_passwd_base
  $groupbase  = $ldapclient::nss_group_base
  $ldapserver = $ldapclient::server

  $svccmd     = hiera('service')

  case $::operatingsystem {
    'FreeBSD': {
      # go pick up portsnap here - we need it.
      require freebsd::portsnap

      $atalk_pkg = "net/netatalk"
      $afp_conf  = "/usr/local/etc/afp.conf"
      $service   = "netatalk"
      # we need krb5 UAM support, so...
      require freebsd::portupgrade
      # install prereqs via packages, *then* build it.
      package{[
        "converters/libiconv",
        "databases/db46",
        "devel/gmake",
        "devel/pkgconf",
        "lang/perl5.16",
        "net/avahi-app",
        "security/libgcrypt",
        "net/openslp",
      ]: ensure => installed } ~> package{$atalk_pkg: ensure => installed, provider => 'portupgrade' }
      # we need avahi for netatalk to properly announce
      require avahi
    }
  }

  # reload handler
  exec{"$svccmd $service restart":
    refreshonly => true,
    subscribe   => Concat[$afp_conf],
  }

  # write out a config
  concat{"$afp_conf":
    owner   => root,
    group   => 0,
    mode    => 0644,
  }

  concat::fragment{'base netatalk/afp config':
    target  => $afp_conf,
    content => template("fileserver/afp.conf.erb"),
    order   => 00,
  }

  # configure/start netatalk
  define share(
    $share         = $title,
    $basedir_regex = undef,
  ) {
    concat::fragment{"afp share: $share":
      target  => $fileserver::netatalk::afp_conf,
      content => template("fileserver/afp.share.conf.erb"),
      order   => 10,
    }
  }

  if $homeserver {
    share{"Homes": basedir_regex => $homepath }
  }

  # configure netatalk to start/start it
  service{"$service": enable => true }

  # install pam config if missing
  file{"/etc/pam.d/netatalk":
    replace => no,
    ensure  => present,
    mode    => 0644,
    owner   => root,
    group   => 0,
    source  => "puppet:///modules/fileserver/pam_d_netatalk",
  }
}
