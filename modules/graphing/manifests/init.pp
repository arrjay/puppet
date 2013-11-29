class graphing (
  $webdir   = hiera('graphing::dir'),		# OS-specific
  $webalias = hiera('graphing::webalias'),	# preferred global
) {
  include mrtg					# pick up rrdtool, eh?
  # base class for graphing - pick up the html dir, and schedule all jobs :)
  $package = hiera('graphing::packages')	# notably, our graph scripts use 'declare -A' and thus require bash 4.x
						# however, there is no good way in puppet to specify that! ask for the latest and hope.

  package {$package: ensure => latest }

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
}
