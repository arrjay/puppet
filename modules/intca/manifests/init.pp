class intca (
  $subject = 'Subject: C=US, ST=Virginia, L=Mclean, O=Produxi Internetworks, OU=Internal SSL Services, CN=Produxi SSL CA (Internal)',
  $cafile = hiera('intca::file'),
  $cabundles = hiera('intca::systembundles',undef),
  $certdir = hiera('intca::certdir'),
  $packages = hiera('intca::packages',undef),
) {
  if $packages {
    package {$packages: ensure => installed}
  }

  file { "$cafile":
    ensure => present,
    path   => "$cafile",
    source => "puppet:///modules/intca/CA.pem",
    mode   => '0644',
    owner  => 'root',
    group  => '0',
  }
}
