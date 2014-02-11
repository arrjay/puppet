class httpd::apache2 (
  $package		= hiera('httpd::apache2::package'),
  $apachectl		= hiera('httpd::apache2::apachectl'),
  $svcname		= hiera('httpd::apache2::svcname'),
  $cf_file		= hiera('httpd::apache2::configfile'),
  $user			= hiera('httpd::apache2::user'),
  $group		= hiera('httpd::apache2::group'),
  $servertokens         = hiera('httpd::apache2::servertokens'),
  $serverroot		= hiera('httpd::apache2::serverroot'),
  $error_log		= hiera('httpd::apache2::error_log'),
  $error_log_level	= hiera('httpd::apache2::error_log_level'),
  $sendfile		= hiera('httpd::apache2::sendfile'),
  $mmap			= hiera('httpd::apache2::mmap'),
  $timeout		= hiera('httpd::apache2::timeout'),
  $keepalive            = hiera('httpd::apache2::keepalive'),
  $keepalive_timeout	= hiera('httpd::apache2::keepalive_timeout'),
  $maxkeepaliverequests = hiera('httpd::apache2::maxkeepaliverequests'),
  $mimetypes		= hiera('httpd::apache2::mimetypes'),
  $default_mimetype	= hiera('httpd::apache2::default_mimetype'),
  $mimemagic		= hiera('httpd::apache2::mime_magicfile'),
  $log_formats		= hiera('httpd::apache2::log_formats'),
  $pidfile		= hiera('httpd::apache2::pidfile',undef),
  $prefork_opts		= hiera('httpd::apache2::prefork_opts'),
  $worker_opts		= hiera('httpd::apache2::worker_opts'),
  $serveradmin		= hiera('httpd::apache2::serveradmin'),
  $usecanonicalname	= hiera('httpd::apache2::usecanonicalname'),
  $documentroot		= hiera('httpd::apache2::documentroot'),
  $documentrootopts	= hiera('httpd::apache2::documentrootopts'),
  $svccmd		= hiera('service'),
  $serversignature	= hiera('httpd::apache2::serversignature','Off'),
  $directoryindices	= hiera('httpd::apache2::directoryindices','index.html'),
  $indexoptions		= hiera('httpd::apache2::indexoptions',undef),
  $indexignore		= hiera('httpd::apache2::indexignore',undef),
  $blockhtfiles		= hiera('httpd::apache2::blockhtfiles',true),
  $accessfile		= hiera('httpd::apache2::accessfile','.htaccess'),
  $readmename		= hiera('httpd::apache2::readmename','README.html'),
  $headername		= hiera('httpd::apache2::headername','HEADER.html'),
  $userdir_enable	= hiera('httpd::apache2::userdir_enable',false),
  $userdir_name		= hiera('httpd::apache2::userdir_name','disabled'),
  $userdir_targetroots  = hiera('httpd::apache2::userdir_targetroots',undef),
  $userdir_allowoverrides = hiera('httpd::apache2::userdir_allowoverrides',undef),
  $userdir_options	= hiera('httpd::apache2::userdir_options',undef),
  $userdir_acl		= hiera('httpd::apache2::userdir_acl',undef),
  $loghostnames         = hiera('httpd::apache2::loghostnames',false),
  $additional_http_opts	= hiera('httpd::apache2::additional_http_opts',undef),
  $access_log_format	= hiera('httpd::apache2::access_log_format'),
  $log_file		= hiera('httpd::apache2::log_file'),
  $iconalias		= hiera('httpd::apache2::iconalias','/icons/'),
  $icondir		= hiera('httpd::apache2::iconpath',undef),
  $icon_byencoding	= hiera('httpd::apache2::icon_byencoding',undef),
  $icon_bytype		= hiera('httpd::apache2::icon_bytype',undef),
  $icon_byname		= hiera('httpd::apache2::icon_byname',undef),
  $descriptions		= hiera('httpd::apache2::descriptions',undef),
  $defaulticon		= hiera('httpd::apache2::icon_default',undef),
  $davlockdb		= hiera('httpd::apache2::davlockdb',undef),
  $scriptaliases	= hiera('httpd::apache2::scriptaliases',undef),
  $scriptdir_acl	= hiera('httpd::apache2::scriptdir_acl',undef),
  $language_map		= hiera('httpd::apache2::language_map',undef),
  $language_priority	= hiera('httpd::apache2::language_priority',['en', 'es']),
  $forcelangresult      = hiera('httpd::apache2::forcelanguagepriority',['Prefer','Fallback']),
  $charsets		= hiera('httpd::apache2::charsets',['UTF-8']),
  $encodings		= hiera('httpd::apache2::encodings',undef),
  $filetypes		= hiera('httpd::apache2::filetypes',undef),
  $handlers		= hiera('httpd::apache2::handlers',undef),
  $outputfilters	= hiera('httpd::apache2::outputfilters',undef),
  $error_alias		= hiera('httpd::apache2::error_alias','/error/'),
  $error_root		= hiera('httpd::apache2::error_root',undef),
  $error_i18n		= hiera('httpd::apache2::error_i18n',false),
  $error_documents	= hiera('httpd::apache2::error_documents',undef),
  $browsermatch		= hiera('httpd::apache2::browserfixups',undef),
  $additional_http_mods = hiera('httpd::apache2::modules',undef),
  $tmpdir		= undef,	# Could be unset as well...
  $sites		= hiera('httpd::apache2::sites',{ "*" => { port => "80", root => "/srv/www", }, }),
) {
  # unwind sites into VirtualHost blocks. NOTE: this is not...*quite* equivalent to nginx config stanzas.

  # holder of global ciphers, prefer_server_ciphers, session_cache, session_timeout
  $ssl_opts = hiera('httpd::apache2::ssl_opts',undef)

  package { $package: ensure => installed }

  service { $svcname: enable => true }

  # used in the template to figure out the correct includes
  $osrel = "$::operatingsystem$::operatingsystemmajrelease"

  file {$cf_file:
    content => template("httpd/apache2.conf.erb")
  }

  exec { "restart apache2":
    refreshonly => true,
    command     => "$svccmd $svcname restart",
    subscribe   => File[$cf_file],
#    onlyif      => "$apachectl -t -f $cf_file",
  }
}
