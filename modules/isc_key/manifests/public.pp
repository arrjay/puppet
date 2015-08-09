define isc_key::public (
  $name,
  $path  = $title,
  $owner = 'root',
  $group = 'named',
  $mode  = '0640',
) {
  $keyname = $name
  $keyhash = hiera("isc_key::$name")
  $keydata = $keyhash[data]
  $keytype = $keyhash[type]
  file{$path:
    owner   => $owner,
    group   => $group,
    mode    => $mode,
    content => template('isc_key/public.erb')
  }
}
