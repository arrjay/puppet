class rpmrepo::rpmfusion-free-updates (
) {
  yumrepo {'rpmfusion-free-updates':
    enabled  => '1',
    gpgcheck => '1',
    mirrorlist => 'http://mirrors.rpmfusion.org/mirrorlist?repo=free-el-updates-released-6&arch=$basearch',
  }
  file {'/etc/pki/rpm-gpg/RPM-GPG-KEY-rpmfusion-free-el-6':
    owner  => root,
    group  => 0,
    mode   => 0644,
    source => 'puppet:///modules/rpmrepo/RPM-GPG-KEY-rpmfusion-free-el-6',
    before => Exec['add rpmfusion-free-updates gpgkey'],
  }
  exec{'add rpmfusion-free-updates gpgkey':
    command => "/bin/rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-rpmfusion-free-el-6",
    unless => "/bin/rpm -qi gpg-pubkey-849c449f-4cb9df30"
  }
}
