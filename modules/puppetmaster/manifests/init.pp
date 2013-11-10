# Stuff useful for a puppetmaster
class puppetmaster {
  package { 'hiera-gpg':
    ensure   => 'latest',
    provider => 'gem',
  }
}
