class monitoring (
) {
  $vmpackages = hiera('monitoring::vmware_packages',undef)
  $packages = hiera('monitoring::packages',undef)
  $services = hiera('monitoring::services',undef)
  include mrtg
  include crontask

  if $::virtual == 'vmware' {
    if $vmpackages {
      package{$vmpackages: ensure => installed}
    }
  }

  if $packages {
    package{$packages: ensure => installed}
  }
  if $services {
    service{$services: enable => true, ensure => running }
  }

  $mrtgdir = "$mrtg::dir/disks"

  file {"$mrtgdir":
    owner  => root,
    group  => 0,
    ensure => directory,
    mode   => 0755,
  }

  # the disk monitoring script has all the RRD creation and OS logic *inside it*. Just install and cron.
  file {"$crontask::dir/rrdgraph-disks.sh":
    owner => root,
    group => 0,
    source => "puppet:///modules/monitoring/rrdgraph-disks.sh",
    mode => 0755,
  }

  cron {"rrdgraph-disks":
    command => "$crontask::dir/rrdgraph-disks.sh $mrtgdir",
    user => root,
    minute => '*/5',
  }

  $ifdir = "$mrtg::dir/interfaces"

  file {"$ifdir":
    owner  => root,
    group  => 0,
    ensure => directory,
    mode   => 0755,
  }

  # the interface monitoring script works the same
  file {"$crontask::dir/rrdgraph-if.sh":
    owner => root,
    group => 0,
    source => "puppet:///modules/monitoring/rrdgraph-if.sh",
    mode => 0755,
  }

  cron {"rrdgraph-if":
    command => "$crontask::dir/rrdgraph-if.sh $ifdir",
    user => root,
    minute => '*/5',
  }

}
