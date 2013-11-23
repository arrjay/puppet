class httpd::nginx (
  $package		= hiera('httpd::nginx::package'),
  $binary		= hiera('httpd::nginx::bin'),
  $svcname		= hiera('httpd::nginx::svcname'),
  $cf_file		= hiera('httpd::nginx::configfile'),
  $user			= hiera('httpd::nginx::user'),
  $group		= hiera('httpd::nginx::group'),
  $worker_processes  	= hiera('httpd::nginx::worker_processes'),
  $worker_connections	= hiera('httpd::nginx::worker_connections'),
  $error_log		= hiera('httpd::nginx::error_log'),
  $sendfile		= hiera('httpd::nginx::sendfile'),
  $keepalive_timeout	= hiera('httpd::nginx::keepalive_timeout'),
  $default_mimetype	= hiera('httpd::nginx::default_mimetype'),
  $log_format           = hiera('httpd::nginx::log_format'),
  $svccmd		= hiera('service'),
  $log_file		= undef,
  $pidfile		= undef,
  $tmpdir		= undef,	# Could be unset as well...
  $top_includes		= undef,	# becuase unset is valid here
  $sites		= undef,
) {
  if ($pidfile) {
    $_pidfile = $pidfile
  } else {
    $_pidfile = hiera('httpd::nginx::pidfile',undef)
  }
  if ($log_file) {
    $_log_file = $log_file
  } else {
    $_logfile = hiera('httpd::nginx::log_file',undef)
  }

  if ($sites) {
    $_sites = $sites
  } else {
    $_sites = hiera_hash('httpd::nginx::sites',{ 'localhost' => { port => '80', locations => { '/' => { root => '/srv/www', }, }, }, })
  }

  package { $package: ensure => installed }

  service { $svcname: enable => true }

  if $tmpdir {
    file {$tmpdir:
      ensure => directory,
      owner  => $user,
      group  => $group,
      mode   => '0755',
    }
  }

  file {$cf_file:
    content => template("httpd/nginx.conf.erb")
  }

  exec { "restart nginx":
    refreshonly => true,
    command     => "$svccmd $svcname restart",
    subscribe   => File[$cf_file],
    onlyif      => "$binary -t -c $cf_file",
  }
}
