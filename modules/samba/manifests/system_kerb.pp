# as a class to break dependency cycles
class samba::system_kerb (
) {
  # actually configure the system krb5, then samba
  require aa::krb5
  include samba
  concat::fragment{"$samba::config: [global] - domain - krb5 keytab":
    target  => 'smb.conf',
    content => "  kerberos method = secrets and keytab\n",
    order   => '11',
  }
}
