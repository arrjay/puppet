class nut::monitoring {
  include nut
  # we need to write a cron task script...
  include crontask
  # which writes files to a mrtg directory...and uses rrdtool.
  include mrtg

  $mrtgdir = "$mrtg::dir/ups"

  file {"$mrtgdir":
    owner  => root,
    group  => 0,
    ensure => directory,
    mode   => 0755,
  }

  # fuck this declarative language. shell script to create the rrds needed...
  file {"$crontask::dir/rrdtool-ups.sh":
    owner   => root,
    group   => 0,
    source  => "puppet:///modules/nut/rrdtool-ups.sh",
    mode    => 0755,
  }

  # shell script to graph ups statistics.
  file {"$crontask::dir/rrdgraph-ups.sh":
    owner   => root,
    group   => 0,
    source  => "puppet:///modules/nut/rrdgraph-ups.sh",
    mode    => 0755,
  }

  # run this if we bounced nut. easiest.
  exec {"$crontask::dir/rrdtool-ups.sh":
    command     => "$crontask::dir/rrdtool-ups.sh $mrtgdir",
    refreshonly => true,
    require     => File["$mrtgdir"],
    subscribe   => [ Exec["restart $nut::svc"], File["$crontask::dir/rrdtool-ups.sh"], File["$crontask::dir/rrdgraph-ups.sh"], ],
  }

  cron {"rrdgraph-ups":
    command => "$crontask::dir/rrdgraph-ups.sh $mrtgdir",
    user    => root,
    minute  => '*/5',
  }
}
