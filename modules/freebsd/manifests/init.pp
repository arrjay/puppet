class freebsd {
  # freebsd-specific stuff. at the moment, some symlink enforcement...
  if $::kernel == 'FreeBSD' {
    file { '/bin/bash':
      ensure => 'link',
      target => '/usr/local/bin/bash',
    }
  }
}
