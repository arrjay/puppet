class snmp (
  $packages     = hiera('snmp::packages',undef),
  $config       = hiera('snmp::conf',undef),
  $services     = hiera('snmp::services',undef),
  $graphtokedir = hiera('snmp::factdir',undef),
  $ROCommunity  = hiera('snmp::rocommunity',public),
  $SysLocation  = hiera('snmp::syslocation','unknown'),
  $SysContact   = hiera('snmp::syscontact','unknown'),
) {
  if $packages {
    package{$packages: ensure => installed}
  }

  if $services {
    service{$services: enable => true, ensure => running}
  }

  if $config {
    if ! $graphtokedir {
      notice ("writing out an snmp config, but I have no way to tell the autographing module!")
    } else {
      exec {"/bin/mkdir -p $graphtokedir":
        creates => $graphtokedir,
      }
    }
    file{$config:
      owner   => root,
      group   => 0,
      mode    => '0640',
      content => template("snmp/snmpd.conf.erb"),
      notify  => Service[$services],
    }
  }
}
