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
  $actions		= hiera('httpd::apache2::actions',undef),
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
  # pick up SSL if needed
  include httpd

  # unwind sites into VirtualHost blocks. NOTE: this is not...*quite* equivalent to nginx config stanzas.

  # holder of global ciphers, prefer_server_ciphers, session_cache, session_timeout
  $ssl_opts = hiera('httpd::apache2::ssl_opts',undef)

  package { $package: ensure => installed }

  service { $svcname: enable => true }

  # used in the template to figure out the correct includes
  $osrel = "$::operatingsystem$::operatingsystemmajrelease"

  # call before we go to template, so we can set up handlers for php :)
  if defined("phpstack") {
    # complete the phpstack class before executing this code.
    include phpstack
    case $::operatingsystem {
      # on FreeBSD we are using php5 via cgi!
      'FreeBSD': {
        # this is the hash map used from hiera to set handlers. it's kinda brittle.
        $php_cgi_handler = { 'application/x-httpd-php5' => { extensions => ['php'] } }
        $php_cgi_action  = { 'application/x-httpd-php5' => '/cgi-bin/php-cgi' }
        # this must be a hardlink.
        exec{"/bin/ln /usr/local/bin/php-cgi /usr/local/www/apache24/cgi-bin/php-cgi":
          creates => "/usr/local/www/apache24/cgi-bin/php-cgi",
        }
        if $handlers {
          $_handlers = merge($php_cgi_handler, $handlers)
        } else {
          $_handlers = $php_cgi_handler
        }
        if $actions {
          $_actions = merge($php_cgi_action, $actions)
        } else {
          $_actions = $php_cgi_action
        }
      }
      default: {
        # copy _handler to handler - *shrug*
        $_handlers             = $handlers
        $_actions              = $actions
      }
    }
  } else {
    # still need that copy
    $_handlers             = $handlers
    $_actions              = $actions
  }

  concat{$cf_file:
    owner => root,
    group => 0,
    mode  => 0644,
  }

  concat::fragment{'base httpd config':
    target  => $cf_file,
    content => template("httpd/apache2.conf.erb"),
    order   => 00,
  }

  concat::fragment{'base http module config':
    target  => $cf_file,
    content => template("httpd/apache2.modules.${osrel}.erb"),
    order   => 10,
  }

  define module(
    $modname = $title,
    $modpath = undef,
    $order   = 1,
  ) {
    $fragorder = 10 + $order
    concat::fragment{'http_module: $modname':
      target  => $httpd::apache2::cf_file,
      content => template("httpd/apache2.addlmod.conf.erb"),
      order   => $fragorder,
    }
  }

  if $additional_http_mods {
    create_resources( module, $additional_http_mods )
  }

  concat::fragment{'non-vhost http site config':
    target  => $cf_file,
    content => template("httpd/apache2.base.conf.erb"),
    order   => 30,
  }

  define site(
    $port                      = '80',
    $binding                   = '*',
    $servername                = $title,
    $ssl_cert                  = undef,
    $ssl_key                   = undef,
    $ssl_ciphers               = undef,
    $ssl_protocols             = undef,
    $ssl_session_timeout       = undef,
    $ssl_session_cache         = undef,
    $ssl_prefer_server_ciphers = undef,
    $access_log                = undef,
    $access_log_fmt            = 'combined', 
    $error_log                 = undef,
    $root                      = undef,
    $locations                 = undef,
    $directory                 = undef,
    $additional_site_opts      = undef,
    $order                     = 1,
  ) {
    $fragorder = 40 + $order
    concat::fragment{"site: $servername":
      target  => $httpd::apache2::cf_file,
      content => template("httpd/apache2.site.erb"),
      order   => $fragorder,
    }
  }

  if $sites {
    create_resources( site, $sites )
  }

  exec { "restart apache2":
    refreshonly => true,
    command     => "$svccmd $svcname restart",
    subscribe   => File[$cf_file],
#    onlyif      => "$apachectl -t -f $cf_file",
  }
}
