class freebsd {
  # freebsd-specific stuff. at the moment, some symlink enforcement...
  if $::kernel == 'FreeBSD' {
    file { '/bin/bash':
      ensure => 'link',
      target => '/usr/local/bin/bash',
    }
    if $::pkgng_enabled {
      file { '/usr/local/etc/pkg.conf':
        ensure => 'present',
        owner  => 'root',
        group  => 0,
        mode   => 0644,
        source => "puppet:///modules/freebsd/pkg.conf",
      }
    }
  }
}
