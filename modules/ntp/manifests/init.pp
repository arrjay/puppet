class ntp (
  $upstream = hiera('ntp::servers',undef),
  $packages = hiera('ntp::packages',undef),
  $conf = hiera('ntp::configfile',undef),
  $svc = hiera('ntp::service',undef),
  $svccmd = hiera('service',undef),
  $role = hiera('ntp::role','client'),
) {
  require stdlib
  # get number of servers
  $servcount = size($upstream)
  # randomize ntp server selection
  $random = fqdn_rand($servcount,169291)
  # only do things if we defined the NTP service for this platform
  # figure out if we're on a VM *host*
  if $::virtual =~ /^xen0$/ {
    $virtualserver = true
  }
  if $svc {
    service{$svc: enable => true}
    file{$conf:
      owner   => root,
      group   => 0,
      mode    => 0644,
      content => template("ntp/ntp.conf.erb"),
      notify  => Exec["$svccmd $svc restart"], 
    }
    exec{"$svccmd $svc restart":
      refreshonly => true,
    }
  }
}
