class monitoring (
) {
  $packages = hiera('monitoring::packages',undef)
  $services = hiera('monitoring::services',undef)
  include mrtg
  include crontask

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
}
