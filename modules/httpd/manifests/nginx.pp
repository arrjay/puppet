class httpd::nginx {
  case $::operatingsystem {
    'FreeBSD': {
      $package = "www/nginx"
      $svc     = "nginx"
      $cf_file = "/usr/local/etc/nginx/nginx.conf"
      $tmpdir  = "/var/tmp/nginx"
      $user    = "www"
      $group   = "www"
      $bin     = "/usr/local/sbin/nginx"
    }
  }

  $config = hiera_hash('httpd::nginx')

  package { $package: ensure => installed }

  service { $svc: enable => true }

  file {$tmpdir:
    ensure => directory,
    owner  => $user,
    group  => $group,
    mode   => '0755',
  }

  file {$cf_file:
    content => template("httpd/nginx.conf.erb")
  }

  exec { "restart nginx":
    refreshonly => true,
    command     => "/usr/sbin/service $svc restart",
    subscribe   => File[$cf_file],
    onlyif      => "$bin -t -c $cf_file",
  }
}
