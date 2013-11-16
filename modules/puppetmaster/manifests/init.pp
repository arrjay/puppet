# Stuff useful for a puppetmaster
class puppetmaster {
  case $::operatingsystem {
    'CentOS': {
      package { ['ruby-devel', 'gcc']:
        ensure => 'installed',
      }
    }
  }
  package { ['hiera-gpg', 'deep_merge']:
    ensure   => 'latest',
    provider => 'gem',
  }
}
