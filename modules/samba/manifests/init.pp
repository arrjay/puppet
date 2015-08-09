class samba (
  $workgroup,
  $description,
  $realm = hiera('aa::krb5::realm',undef),
  $secmode = 'user',
  $workgroup,
) {
  # bits
  case $::osfamily {
    'RedHat': {
      $config   = '/etc/samba/smb.conf',
      $packages = [ 'samba' ],
      $services = [ 'smb' ],
    }
  }

  # install packages if needed
  ensure_packages($packages)

  # concat anchor for config - note that we just tag it smb.conf, not the actual path
  concat{'smb.conf':
    path    => $config,
    require => Package[$packages],
  }

  # use .each to iterate through global section templates
  $templates = { 'base'	        => '00',
                 'domain'       => '10',
                 'log'          => '20',
                 'shareopts'    => '35',
                 'print'        => '39',
                 'winbind'      => '40',
                 'idmap'        => '50',
                 'idmap_domain' => '55'}

  $templates.each |$sectname, $order| {
    concat::fragment{"$config: [global] - domain - $sectname":
      target  => 'smb.conf',
      order   => $order,
      content => template("samba/global/$sectname.erb"),
    }
  }

  # start share mapping here
  $share_order = '65'
}

