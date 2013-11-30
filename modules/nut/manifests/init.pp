class nut (
  $mode = undef,
) {
  # generally, only fire if facter finds a UPS -or- explicitly asked to configure a serial ups
  # TODO: serial ups support
  if (($::ups) or ($mode)) {
    # these defines hold the passwords for upsmon, upsmast, root
    $upsmon_pass = hiera('nut::upsmon_pass')
    $upsmast_pass = hiera('nut::upsmast_pass')
    $root_pass = hiera('nut::root_pass')
    # os execution account
    $user = hiera('nut::user')
    $group = hiera('nut::group')
    # init name
    $svc = hiera('nut::svcname')
    $service = hiera('service')
    # install this
    $packages = hiera('nut::packages')
    # ups units defined here
    $upsconf  = hiera('nut::ups_conf')
    # needed on debian, not used on centos...
    $nutconf  = hiera('nut::nut_conf')
    # upsd users defined here
    $userconf = hiera('nut::upsd_users')
    # config for the server daemon
    $upsdconf = hiera('nut::upsd_conf')
    # config for the monitor daemon
    $monconf  = hiera('nut::upsmon_conf')

    # if we were explicitly handed a mode, use that
    if ($mode) {
      $_mode = $mode
    } else {
      # if there is a comma in here, turn on netserver. we have multiple UPSes plugged in...
      if $::ups =~ /,/ {
        $_mode = 'netserver'
        # allow this guy to listen on everything. sure.
        # no augeas lens for this file :(
        exec {"$upsdconf: LISTEN * 3493":
          command => "/bin/echo 'LISTEN * 3493' >> $upsdconf",
          unless  => "/bin/grep -qFx 'LISTEN * 3493' $upsdconf",
          notify  => Exec["restart $svc"],
        }
      # we should also flip to netserver if we are a virtualization host (though you probably set mode)
      } elsif $::virtual == 'xen0' {
        $_mode = 'netserver'
        # if we have a vmm interface, add a listening line for it
        # note that this code doen't run if we satisfied the first if statement (which installed a global!)
        if $::ipaddress_vmm {
          exec {"$upsdconf: LISTEN $::ipaddress_vmm 3493":
            command => "/bin/echo 'LISTEN $::ipaddress_vmm 3493' >> $upsdconf",
            unless  => "/bin/grep -qFx 'LISTEN $::ipaddress_vmm 3493' $upsdconf",
            notify  => Exec["restart $svc"],
          }
        }
      # we should flip to netclient if we are a VM
      } elsif $::virtual =~ /^kvm$/ {
        $_mode = 'netclient'
      } else {
      # we found an ups, we're not running vms or talking to anyone else!
        $_mode = 'standalone'
      }
    }

    # load ups definitions from hiera
    $upsdefs = hiera('upsdefs')

    exec { "restart $svc":
      refreshonly => true,
      command     => "$service $svc restart",
      subscribe   => File[$nutconf, $upsconf, $userconf, $monconf],
    }
    
    package { $packages: ensure => installed }

    file {$nutconf:
      content => template("nut/nut.conf.erb"),
      owner   => root,
      group   => root,
    }

    file {$upsconf:
      content => template("nut/ups.conf.erb"),
      owner   => root,
      group   => $group,
      mode    => 0640,
    }

    file {$userconf:
      content => template("nut/upsd.users.erb"),
      owner   => root,
      group   => $group,
      mode    => 0640,
    }

    file {$monconf:
      owner   => root,
      group   => $group,
      mode    => 0640,
    }

    case $_mode {
      'standalone', 'netserver': {
        augeas{"$monconf: ups":
          changes => [
            "set /files/$monconf/MONITOR/system/upsname ups",
            "rm /files/$monconf/MONITOR/system/hostname",
            "set /files/$monconf/MONITOR/powervalue 1",
            "set /files/$monconf/MONITOR/username upsmast",
            "set /files/$monconf/MONITOR/password $upsmast_pass",
            "set /files/$monconf/MONITOR/type master",
          ],
          notify => Exec["restart $svc"],
        }
      }
      'netclient': {
        #augeas{"$monconf: ups@"
      }
    }

  }
}
