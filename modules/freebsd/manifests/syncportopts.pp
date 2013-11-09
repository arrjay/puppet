class freebsd::syncportopts {
  vcsrepo { "/var/db/ports":
    ensure => latest,
    provider => git,
    source => "https://github.com/arrjay/freebsd-port-options.git",
  }
}
