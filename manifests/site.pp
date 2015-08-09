# provide a default path for exec blocks here.
Exec {
  path => $osfamily ? {
    default => "/usr/sbin:/sbin:/usr/bin:/bin:/usr/local/sbin:/usr/local/bin"
  }
}

# provide owner group perm defaults here
File {
  owner => $osfamily ? {
    default => 'root',
  }
}
File {
  group => $osfamily ? {
    default => 'root',
  }
}
File {
  mode => '0644',
}
Concat {
  owner => $osfamily ? {
    default => 'root',
  }
}
Concat {
  group => $osfamily ? {
    default => 'root',
  }
}
Concat {
  mode => '0644',
}

$resources=hiera_hash('resources', {})
$resources.keys().each |$resourcetype| {
  $resource_entries=$resources[$resourcetype]
  create_resources($resourcetype,$resource_entries)
}

hiera_include('classes')
