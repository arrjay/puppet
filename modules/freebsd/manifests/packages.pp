class freebsd::packages {
  # Concern yourself mostly about getting puppet updated here :)
  package { [
      "lang/ruby19",
      "ports-mgmt/portupgrade",
      "textproc/augeas",
      "sysutils/puppet",
      "sysutils/rubygem-facter",
      "sysutils/rubygem-hiera",
    ]:
    ensure => latest, provider => 'portupgrade', }

  # use the default package provider here, we don't mind as much.
  package { [
      "databases/db41",
      "textproc/jq",
      "devel/git",
      "lang/perl5.14",
    ]:
    ensure => installed }

  # Require portsnap, git repo sync before attempting portupgrade work!
  Package <| provider == 'portupgrade' |> {
    require => Exec["portsnap update"],
  }
}
