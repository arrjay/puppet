class freebsd::portupgrade {
  # install portupgrade :)
  package { 'ports-mgmt/portupgrade': ensure => installed }

  # force a sync
  Package <| provider == 'portupgrade' |> {
    require => Exec["portsnap update"],
  }
}
