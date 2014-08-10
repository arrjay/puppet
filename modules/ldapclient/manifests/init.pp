class ldapclient (
  $server          = hiera('ldapclient::server'),
  $base            = hiera('ldapclient::basedn'),
  $cafile          = hiera('ldapclient::cafile',undef),
  $ldap_config     = hiera('ldapclient::conffile',undef),
  $nss_config      = hiera('ldapclient::nss_conf',undef),
  $nss_filter      = hiera('ldapclient::nss_filter','objectclass=user'),
  $min_uid         = hiera('ldapclient::nss_min_uid','100'),
  $max_uid         = hiera('ldapclient::nss_max_uid','64000'),
  $userattr        = hiera('ldapclient::nss_user_attr','uid'),
  $groupattr       = hiera('ldapclient::nss_group_attr','gid'),
  $nss_passwd_base = hiera('ldapclient::nss_passwd_base',undef),
  $nss_group_base  = hiera('ldapclient::nss_group_base',undef),
  $binddn          = hiera('ldapclient::binddn',undef),
  $bindpw          = hiera('ldapclient::bindpw',undef),
  $sssd_config     = hiera('ldapclient::sssd_config',undef),
) {
  include krbclient
  include intca
  $packages = hiera('ldapclient::packages',undef)
  $services = hiera('ldapclient::services',undef)

  $krb_domain = $krbclient::realm

  if $packages {
    package{$packages: ensure=> installed}
  }

  if $services {
    service{$services: enable=> true, ensure => running}
  }

  if $ldap_config {
    file {$ldap_config:
      owner   => root,
      group   => 0,
      mode    => 0644,
      content => template("ldapclient/ldap.conf.erb"),
    }
  }

  if $nss_config {
    file {$nss_config:
      owner   => root,
      group   => 0,
      mode    => 0644,
      content => template("ldapclient/nss_ldap.conf.erb"),
    }
  }

  if $sssd_config {
    file {$sssd_config:
      owner   => root,
      group   => 0,
      mode    => 0600,
      content => template("ldapclient/sssd.conf.erb"),
    }
  }

  define ldap_enable($database = $title) {
    case $::operatingsystem {
      'FreeBSD': {
        $nss = '/etc/nsswitch.conf'
        augeas { "$nss: disable compat for $database lookup":
          changes => [
            "set /files/$nss/database[ . = '$database' ]/service[ . = 'compat' ] 'files'",
          ],
          onlyif => "match /files/$nss/database[ . = '$database' ]/service[ . = 'compat' ] size != 0",
          before => Augeas["$nss: enable ldap for $database lookup"],
        }
        augeas { "$nss: enable ldap for $database lookup":
          changes => [
            "set /files/$nss/database[ . = '$database' ]/service[ last() + 1 ] 'ldap'",
          ],
          onlyif => "match /files/$nss/database[ . = '$database' ]/service[ . = 'ldap' ] size == 0 and match /files/$nss/database[. = '$database' /service[ . = 'compat' size != 0",
        }
      }
      'CentOS': {
        $nss = '/etc/nsswitch.conf'
        augeas { "$nss: enable sss for $database lookup":
          changes => [
            "set /files/$nss/database[ . = '$database' ]/service[ last() + 1 ] 'sss'",
          ],
          onlyif => "match /files/$nss/database[ . = '$database' ]/service[ . = 'sss' ] size == 0",
        }
      }
    }
  }

  ldap_enable{"passwd":}
  ldap_enable{"group":}
  if $::operatingsystem == 'CentOS' {
    ldap_enable{"shadow":}
  }
}
