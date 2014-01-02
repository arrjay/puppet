class krbclient (
  $realm = hiera('krbclient::realm')
) {
  $svccmd = hiera('service')
  define pam_k5_aug($target = $title) {
    case $::operatingsystem {
      'FreeBSD': {
        # auth            sufficient      pam_krb5.so             no_warn try_first_pass
        augeas {"$target: enable krb5 auth":
          changes => [
            "ins 100 before /files/$target/*[type = 'auth'][module = 'pam_unix.so']",
            "set /files/$target/100/type 'auth'",
            "set /files/$target/100/control 'sufficient'",
            "set /files/$target/100/module 'pam_krb5.so'",
            "set /files/$target/100/argument[last()+1] 'no_warn'",
            "set /files/$target/100/argument[last()+1] 'try_first_pass'",
          ],
          onlyif => "match /files/$target/*[type = 'auth'][module = 'pam_krb5.so'] size == 0",
        }
      }
    }
  }
  case $::operatingsystem {
    'FreeBSD': {
      exec{"restart sshd":
        command     => "$svccmd sshd restart",
        refreshonly => true,
      }
      $pam_files = ['/etc/pam.d/sshd', '/etc/pam.d/system']
      pam_k5_aug{$pam_files:} ~> Exec["restart sshd"]
    }
  }
}
