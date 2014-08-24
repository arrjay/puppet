class zpool (
  $pools = hiera('zpools'),
  $noop  = hiera('zpool::noop',true),
) {
  # if this is a linux variant, pull in the zfs module now.
  case $::osfamily {
    'RedHat' : {
      exec {'create hostid':
        command  => 'dd if=/dev/random bs=1 count=4 2>/dev/null|hexdump -e \'"%x\n"\'>/etc/hostid',
        provider => 'shell',
        creates  => '/etc/hostid',
        before   => Package["zfs"],
      }
      file {'/etc/hostid':
        owner  => root,
        group  => 0,
        mode   => 0644,
        before => Package["zfs"],
      }
      yumrepo {'zfs':
        enabled  => '1',
        gpgcheck => '1',
        baseurl  => 'http://archive.zfsonlinux.org/epel/$releasever/$basearch',
        before   => Package['zfs'],
      }
      file {'/etc/pki/rpm-gpg/RPM-GPG-KEY-zfsonlinux':
        owner  => root,
        group  => 0,
        mode   => 0644,
        source => 'puppet:///modules/zpool/RPM-GPG-KEY-zfsonlinux',
        before => Exec['add zfs gpgkey'],
      }
      exec{'add zfs gpgkey':
        command => "/bin/rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-zfsonlinux",
        unless => "/bin/rpm -qi gpg-pubkey-f14ab620-514b76b7",
        before => Yumrepo['zfs'],
      }
      package{'kernel-devel': ensure => present, before => Package["zfs"], }
      package{'zfs': ensure => present}
    }
  }
  $defaults = { noop => $noop }
  # just a basic class around the puppet zpool objects, so we can build from a base.
  create_resources( zpool, $pools, $defaults )
}
