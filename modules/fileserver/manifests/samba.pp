class fileserver::samba (
  $config      = hiera('fileserver::samba_conf'),
  $workgroup   = hiera('fileserver::samba_workgroup'),
  $logspec     = hiera('fileserver::samba_logpath'),
  $logsize     = hiera('fileserver::samba_logsize','50'),
  $comment     = hiera('fileserver::samba_description','Samba Server'),
  $printserver = hiera('fileserver::samba_printing',false),
  $shares      = hiera('fileserver::samba_shares',undef),
  $homeserver  = hiera('fileserver::samba_homeserver',false),
) {
  $svccmd = hiera('service')
  # we use puppetlabs-concat for share definitions.

  # we need kerberos before kicking samba over. WE DO AD.
  include krbclient

  $realm = $krbclient::realm

  # installing samba
  case $::operatingsystem {
    'FreeBSD': {
      $samba_svc = "samba"
      $samba_pkg = "net/samba36"
      require freebsd::portupgrade
      # These are also deps, stored as comments because OMG I ASKED FOR THEM EARLIER >_<
      #  "converters/libiconv",
      #  "devel/gmake",
      #  "devel/pkgconf",
      #  "net/avahi-app",
      package{[
        "devel/libexecinfo",
        "devel/popt",
        "devel/talloc",
        "devel/tevent",
        "net/openldap24-client",
        "print/cups-client",
        "sysutils/libsunacl",
        "databases/tdb",
        "devel/autoconf",
      ]: ensure => installed } ~> package{$samba_pkg: ensure => installed, provider => 'portupgrade' }
    }
  }

  define share(
    $share       = $title,
    $sharepath,
    $comment     = "$title share",
    $browseable  = true,
    $writable    = false,
    $guest_ok    = false,
    $printable   = false,
    $public      = false,
    $read_only   = true,
    $create_mask = undef,
    $dir_mask    = undef,
    $extra       = undef,
  ) {
    concat::fragment{"samba share: $share":
      target  => $fileserver::samba::config,
      content => template("fileserver/smb.share.conf.erb"),
      order   => 10,
    }
  }

  # reload handler
  exec{"$svccmd $samba_svc reload":
    refreshonly => true,
    subscribe   => Concat[$config],
  }

  # configure samba
  concat{$config:
    owner   => root,
    group   => 0,
    mode    => 0644,
  }
  concat::fragment{'base samba config':
    target  => $config,
    content => template("fileserver/smb.conf.erb"),
    order   => 00,
  }

  if $printserver {
    share{"printers": sharepath => "/var/spool/samba", comment => "All Printers", browseable => false, writable => false, guest_ok => false, printable => true, }
  }

  if $homeserver {
    share{"homes": sharepath => undef, browseable => false, read_only => false, }
  }

  if $shares {
    # MAGIC.
    create_resources( share, $shares )
  }

  # configure samba to start/start it
  service {$samba_svc: enable => true, ensure => running}
}
