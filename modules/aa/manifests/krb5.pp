class aa::krb5 (
  $realm,
  $config_pam = false,
) {
  case $::osfamily {
    'RedHat': {
      $config = '/etc/krb5.conf'
    }
  }

  file{$config:
    content => template("aa/krb5.conf.erb"),
  }
}
