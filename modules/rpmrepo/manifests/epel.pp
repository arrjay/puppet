class rpmrepo::epel (
) {
  yumrepo {'epel':
    enabled  => '1',
    gpgcheck => '1',
    mirrorlist => 'https://mirrors.fedoraproject.org/metalink?repo=epel-6&arch=$basearch',
  }
  file {'/etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6':
    owner  => root,
    group  => 0,
    mode   => 0644,
    source => 'puppet:///modules/rpmrepo/RPM-GPG-KEY-EPEL-6',
    before => Exec['add epel gpgkey'],
  }
  exec{'add epel gpgkey':
    command => "/bin/rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6",
    unless => "/bin/rpm -qi gpg-pubkey-c105b9de-4e0fd3a3"
  }
}
