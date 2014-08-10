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

        define sss_auth($target = $title) {
          $pam_sysauth = "/files/etc/pam.d/$target/"
          # 4 augeas calls for 4 different argument sets to sss
          augeas {"pam $target: enable sss auth stack":
            changes => [
              "ins 100 before $pam_sysauth*[type = 'auth'][module = 'pam_deny.so']",
              "set $pam_sysauth/100/type 'auth'",
              "set $pam_sysauth/100/control 'sufficient'",
              "set $pam_sysauth/100/module 'pam_sss.so'",
              "set $pam_sysauth/100/argument[last()+1] 'use_first_pass'",
            ],
            onlyif => "match $pam_sysauth*[type = 'auth'][module = 'pam_sss.so'] size == 0",
          }
          augeas {"pam $target: enable sss account stack":
            changes => [
              "ins 200 before $pam_sysauth*[type = 'account'][module = 'pam_permit.so']",
              "set $pam_sysauth/200/type 'account'",
              "set $pam_sysauth/200/control '[default=bad success=ok user_unknown=ignore]'",
              "set $pam_sysauth/200/module 'pam_sss.so'",
            ],
            onlyif => "match $pam_sysauth*[type = 'account'][module = 'pam_sss.so'] size == 0",
          }
          augeas {"pam $target: enable sss password stack":
            changes => [
              "ins 300 before $pam_sysauth*[type = 'password'][module = 'pam_deny.so']",
              "set $pam_sysauth/300/type 'password'",
              "set $pam_sysauth/300/control 'sufficient'",
              "set $pam_sysauth/300/module 'pam_sss.so'",
              "set $pam_sysauth/300/argument[last()+1] 'use_authtok'",
            ],
            onlyif => "match $pam_sysauth*[type = 'password'][module = 'pam_sss.so'] size == 0",
          }
          augeas {"pam $target: enable sss session stack":
            changes => [
              "ins 400 after $pam_sysauth*[type = 'session'][module = 'pam_unix.so']",
              "set $pam_sysauth/400/type 'session'",
              "set $pam_sysauth/400/control 'optional'",
              "set $pam_sysauth/400/module 'pam_sss.so'",
            ],
            onlyif => "match $pam_sysauth*[type = 'session'][module = 'pam_sss.so'] size == 0",
          }
        }

  if $sssd_config {
    file {$sssd_config:
      owner   => root,
      group   => 0,
      mode    => 0600,
      content => template("ldapclient/sssd.conf.erb"),
    }
    case $::operatingsystem {
      'CentOS' : {
        sss_auth{"system-auth": }
        sss_auth{"password-auth": }
      }
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
