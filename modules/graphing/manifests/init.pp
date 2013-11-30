class graphing (
  $webdir   = hiera('graphing::dir'),		# OS-specific
  $webalias = hiera('graphing::webalias'),	# preferred global
  $graphs   = hiera('graphing::graphs'),	# global
  $colors   = hiera('graphing::colors'),
) {
  include mrtg					# pick up rrdtool, eh?
  # base class for graphing - pick up the html dir, and schedule all jobs :)
  $package = hiera('graphing::packages')	# notably, our graph scripts use 'declare -A' and thus require bash 4.x
						# however, there is no good way in puppet to specify that! ask for the latest and hope.

  include crontask				# we need to lay down monitoring scripts :)

  # install packages we desire
  package {$package: ensure => latest }

  # fish the mrtg data dir out for templates
  $mrtgdir = $mrtg::dir

  # we use an exec block here to create any parents, rather than a file block. eeeeeh.
  exec {"/bin/mkdir -p $webdir":
    creates => $webdir,
    before  => File[$webdir],
  }

  file{"$webdir":
    ensure => directory,
    owner  => root,
    group  => 0,
    mode   => 0755,
  }

  # suck in nginx and configure that now :)
  class {'httpd::nginx':
    sites => { "$::hostname" => { port => '80', locations => { '/' => { root => $webdir, }, }, }, },
  }

  # There should be a good way to ask puppet if I defined a monitoring task.
  # I have no idea what that would be, though :)
  # For the time being, work off the existence of previously defined mrtg dirs via our fact
  # this means you need to run puppet at least twice.
  if ($::graph_targets) {
    $graph_targets = split($::graph_targets, ',')
    if "ups" in $graph_targets {
      file {"$webdir/ups":
        ensure => directory,
        owner  => root,
        group  => 0,
        mode   => 0755,
      }

      file {"$crontask::dir/rrdrender-ups.sh":
        owner   => root,
        group   => 0,
        content => template("graphing/rrdrender-ups.sh.erb"), 
        mode    => '0755',
      }

      cron {"rrdrender-ups":
        command => "$crontask::dir/rrdrender-ups.sh",
        user    => root,
        minute  => "*/5",
      }
    }
    if "temps" in $graph_targets {
      $sensors = hiera('graphing::temps::sensors',undef)
      $fans = hiera('graphing::temps::fans',undef)
      file {"$webdir/temps":
        ensure => directory,
        owner  => root,
        group  => 0,
        mode   => 0755,
      }
      if ($sensors) {
        file {"$crontask::dir/rrdrender-temps.sh":
          owner   => root,
          group   => 0,
          content => template("graphing/rrdrender-temps.sh.erb"),
          mode    => '0755',
        }
        cron {"rrdrender-temps":
          command => "$crontask::dir/rrdrender-temps.sh",
          user    => root,
          minute  => '*/5',
        }
      } else {
        notice("no sensors to graph defined for $::hostname - not installing cron job")
      }
    }
  }
}
