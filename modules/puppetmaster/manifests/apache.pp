class puppetmaster::apache {

  include puppetmaster

  $passenger_ver = '4.0.25'

  case $::operatingsystem {
    'CentOS': {
      package { ['rubygem-rake', 'rubygem-rack', 'rubygem-daemon_controller', 'httpd-devel', 'libcurl-devel']:
        ensure => 'installed',
      }
      package { ['passenger']:
        ensure   => $passenger_ver,
        provider => 'gem',
      }
    }
  }

  file {['/etc/puppet/rack','/etc/puppet/rack/public']:
    ensure => directory,
    owner  => puppet,
    group  => puppet,
  }

  file {'/etc/puppet/rack/config.ru':
    ensure => present,
    owner  => puppet,
    group  => puppet,
    source => "puppet:///modules/puppetmaster/puppet_config.ru",
  }

  exec{'passenger-install-apache2-module':
    command => "/usr/bin/passenger-install-apache2-module -a",
    require => Package['passenger','httpd-devel', 'libcurl-devel'],
    timeout => 0,
    before  => Class['httpd::apache2'],
    creates => "/usr/lib/ruby/gems/1.8/gems/passenger-${passenger_ver}/buildout/apache2/mod_passenger.so"
  }

  class {'httpd::apache2':
    additional_http_mods => { "passenger_module" => "/usr/lib/ruby/gems/1.8/gems/passenger-${passenger_ver}/buildout/apache2/mod_passenger.so" },
    additional_http_opts => [
                            'PassengerHighPerformance on',
                            'PassengerMaxPoolSize 12',
                            'PassengerPoolIdleTime 1500',
                            'PassengerStatThrottleRate 120',
                            "PassengerRoot /usr/lib/ruby/gems/1.8/gems/passenger-${passenger_ver}",
                            'PassengerEnabled on',
                            ],
    sites                 => { "*" => {
                                                    port                 => '8140',
                                                    error_log            => '/var/log/puppet/error_log',
                                                    access_log           => '/var/log/puppet/access_log',
                                                    ssl_cert             => "/var/lib/puppet/ssl/certs/$::fqdn.pem",
                                                    ssl_key              => "/var/lib/puppet/ssl/private_keys/$::fqdn.pem",
                                                    ssl_ciphers          => 'ALL:!ADH:RC4+RSA:+HIGH:+MEDIUM:+LOW:-SSLv2:-EXP',
                                                    ssl_protocols        => '-ALL +SSLv3 +TLSv1',
                                                    ssl_prefer_server_ciphers => true,
                                                    ssl_session_cache    => 'shared:SSL:128m',
                                                    ssl_session_timeout  => '5m',
                                                    additional_site_opts => [
                                                      'RequestHeader set X-SSL-Subject %{SSL_CLIENT_S_DN}e',
                                                      'RequestHeader set X-Client-DN %{SSL_CLIENT_S_DN}e',
                                                      'RequestHeader set X-Client-Verify %{SSL_CLIENT_VERIFY}e',
                                                      '#client_max_body_size 10M;',
                                                      'SSLCARevocationFile /var/lib/puppet/ssl/ca/ca_crl.pem',
                                                      'SSLCACertificateFile /var/lib/puppet/ssl/certs/ca.pem',
                                                      'SSLVerifyClient optional',
                                                      'SSLVerifyDepth 1',
                                                      'SSLOptions +StdEnvVars',
                                                      'RackBaseURI /',
                                                      'RailsEnv production',
                                                    ],
                                                    root                 => '/etc/puppet/rack/public',
                                                    directory            => { '/etc/puppet/rack/' => { config => ['Options None', 'AllowOverride None',
                                                                                                                  'Order allow,deny', 'allow from all'], }, },
                                                    }
                             },
  }

}
