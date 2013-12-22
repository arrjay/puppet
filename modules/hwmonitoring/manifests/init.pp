class hwmonitoring {
  # everything here only makes sense on real hardware.
  # network adapters, CPU loads are monitored NOT HERE.
  if $::virtual =~ /^xen0|physical$/ {
    include mrtg
    include crontask

    $mrtgdir = "$mrtg::dir/temps"

    file {"$mrtgdir":
      owner  => root,
      group  => 0,
      ensure => directory,
      mode   => 0755,
    }

    $packages = hiera('hwmonitoring::packages',undef)
    if $packages {
      package{$packages: ensure => installed}
    }
    $services = hiera('hwmonitoring::services',undef)
    if $services {
      service{$services: enable => true, ensure => running}
    }

    # yep, giant OS case. pretty much all of this is OS-specific
    # figure out what we need...
    case $::operatingsystem {
      'CentOS', 'Ubuntu': {
        if $::processor0 =~ /^Intel.*Core.*$/ {
          $cpudrv = "coretemp"
        } elsif $::processor0 =~ /^AMD E-350$/ {
          $cpudrv = "k10temp"
        }
        if $::productname =~ /^A68I-350 DELUXE$/ {
          $platformdrv = "it87"
          $platformpkg = "it87"
          $relax_acpi = true
        }
      }
      'FreeBSD': {
        # ick ick ick.
      }
    }

    # now do something with it
    # module loading...
    case $::operatingsystem {
      'Ubuntu': {
        exec {"/etc/modules: add $cpudrv":
          command => "/bin/echo $cpudrv >> /etc/modules",
          unless  => "/bin/grep -qFx $cpudrv /etc/modules",
        }
        exec {"/sbin/modprobe $cpudrv":
          unless => "/bin/grep -q ^$cpudrv' ' /proc/modules",
          notify => [ Exec["$crontask::dir/rrdtool-temps.sh"] ],
        }
      }
    }

    # sensors3.conf
    case $::operatingsystem {
      'Ubuntu', 'CentOS': {
        file {"/etc/sensors3.conf":
          owner   => root,
          group   => 0,
          mode    => 0755,
          content => template("hwmonitoring/sensors3.conf.erb"),
          notify  => [ Exec["$crontask::dir/rrdtool-temps.sh"] ],
        }
      }
    }
    # healthd.conf
    case $::operatingsystem {
      'FreeBSD': {
      }
    }

    # rrdtool-hw.sh
    case $::operatingsystem {
      'Ubuntu', 'CentOS': {
        file {"$crontask::dir/rrdtool-temps.sh":
          owner  => root,
          group  => 0,
          source => "puppet:///modules/hwmonitoring/rrdtool-temps.sh",
          mode   => 0755,
          notify => Exec["$crontask::dir/rrdtool-temps.sh"],
        }
      }
    }

    if defined(File["$crontask::dir/rrdtool-temps.sh"]) {
      # run rrdtool-temps to make RRDs
      exec {"$crontask::dir/rrdtool-temps.sh":
        command     => "$crontask::dir/rrdtool-temps.sh $mrtgdir",
        require     => [ File["$crontask::dir/rrdtool-temps.sh"], File[$mrtgdir], ],
        creates     => "$mrtgdir/temps.rrd",
      }
    }

    # rrdgraph-temps to update RRDs
    case $::operatingsystem {
      'Ubuntu', 'CentOS': {
        file {"$crontask::dir/rrdgraph-temps.sh":
          owner  => root,
          group  => 0,
          source => "puppet:///modules/hwmonitoring/rrdgraph-temps.sh",
          mode   => 0755,
        }
        cron {"rrdgraph-temps":
          command => "$crontask::dir/rrdgraph-temps.sh $mrtgdir",
          user    => root,
          minute  => '*/5',
        }
      }
      'FreeBSD': {
        file {"$crontask::dir/rrdgraph-temps.sh":
          owner  => root,
          group  => 0,
          source => "puppet:///modules/hwmonitoring/healthd-rrdgraph-temps.sh",
          mode   => 0755,
        }
        cron {"rrdgraph-temps":
          command => "$crontask::dir/rrdgraph-temps.sh $mrtgdir",
          user    => root,
          minute  => '*/5',
        }
      }
    }
  }
}
