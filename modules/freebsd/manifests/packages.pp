class freebsd::packages {
  # Concern yourself mostly about getting puppet updated here :)
  package { [
      "lang/ruby19",
      "converters/ruby-iconv",
      "devel/ruby-gems",
      "databases/ruby-bdb",
      "devel/ruby-date2",
      "ports-mgmt/portupgrade",
      "textproc/augeas",
      "sysutils/puppet",
      "sysutils/rubygem-facter",
      "devel/rubygem-json_pure",
      "sysutils/rubygem-hiera",
      "sysutils/rubygem-facter",
      "archivers/rubygem-bzip2",
    ]:
    ensure => latest, provider => 'portupgrade', }

  # use the default package provider here, we don't mind as much.
  package { [
      "databases/db41",
      "textproc/jq",
      "devel/autoconf",
      "devel/autoconf-wrapper",
      "devel/automake",
      "devel/automake-wrapper",
      "security/ca_root_nss",
      "ftp/curl",
      "ports-mgmt/dialog4ports",
      "sysutils/dmidecode",
      "textproc/expat2",
      "devel/gettext",
      "devel/git",
      "devel/gmake",
      "misc/help2man",
      "devel/libexecinfo",
      "devel/libffi",
      "converters/libiconv",
      "devel/libtool",
      "textproc/libxml2",
      "textproc/libyaml",
      "devel/m4",
      "lang/perl5.14",
      "devel/p5-Locale-gettext",
      "devel/pkgconf",
    ]:
    ensure => installed }

  # Require portsnap, git repo sync before attempting portupgrade work!
  Package <| provider == 'portupgrade' |> {
    require => Exec["portsnap update"],
  }
}
