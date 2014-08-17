class rpmrepo::arrjay (
) {
  include rpmrepo

  yumrepo {'arrjay':
    enabled  => '1',
    gpgcheck => '1',
    baseurl  => 'http://arrjay.github.io/rpm/el$releasever/$basearch',
  }
  file {'/etc/pki/rpm-gpg/RPM-GPG-KEY-arrjay.net':
    owner  => root,
    group  => 0,
    mode   => 0644,
    source => 'puppet:///modules/rpmrepo/RPM-GPG-KEY-arrjay.net',
    before => Exec['add arrjay gpgkey'],
  }
  exec{'add arrjay gpgkey':
    command => "/bin/rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-arrjay.net",
    unless => "/bin/rpm -qi gpg-pubkey-e564a4c8-515734c3",
    before => Yumrepo['arrjay'],
  }
}
