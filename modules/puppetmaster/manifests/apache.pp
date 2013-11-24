class puppetmaster::nginx {

  include puppetmaster

  case $::operatingsystem {
    'CentOS': {
      package { ['rubygem-rake', 'rubygem-rack', 'rubygem-passenger']:
        ensure => 'installed',
      }
    }
  }

  #package { ['hiera-gpg', 'deep_merge']:
  #  ensure   => 'latest',
  #  provider => 'gem',
  #}

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

  class {'httpd::nginx':
    additional_http_opts => [
                            'tcp_nopush on;',
                            'passenger_root /usr/share/rubygems/gems/passenger-3.0.21;',
                            'passenger_ruby /usr/bin/ruby;',
                            'passenger_max_pool_size 15;',
                            ],
    sites                 => { "$::hostname $::fqdn puppet puppet.$::domain" => {
                                                    port                 => '8140 ssl',
                                                    error_log            => '/var/log/puppet/error_log',
                                                    access_log           => '/var/log/puppet/access_log',
                                                    ssl_cert             => "/var/lib/puppet/ssl/certs/$::fqdn.pem",
                                                    ssl_key              => "/var/lib/puppet/ssl/private_keys/$::fqdn.pem",
                                                    ssl_ciphers          => 'SSLv3:-LOW:-EXPORT:RC4+RSA',
                                                    ssl_protocols        => 'SSLv3 TLSv1',
                                                    ssl_prefer_server_ciphers => true,
                                                    ssl_session_cache    => 'shared:SSL:128m',
                                                    ssl_session_timeout  => '5m',
                                                    additional_site_opts => [
                                                      'client_max_body_size 10M;',
                                                      'passenger_enabled on;',
                                                      'passenger_set_cgi_param HTTP_X_CLIENT_DN $ssl_client_s_dn;',
                                                      'passenger_set_cgi_param HTTP_X_CLIENT_VERIFY $ssl_client_verify;',
                                                      'ssl_crl /var/lib/puppet/ssl/ca/ca_crl.pem;',
                                                      'ssl_client_certificate /var/lib/puppet/ssl/certs/ca.pem;',
                                                      'ssl_verify client optional;',
                                                      'ssl_verify_depth 1;',
                                                    ],
                                                    locations		 => { '/' => { root => '/etc/puppet/rack/public', }, },
                                                    }
                             },
  }

}
