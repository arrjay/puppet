# provide a default path for exec blocks here.
Exec {
  path => $osfamily ? {
    default => "/usr/sbin:/sbin:/usr/bin:/bin:/usr/local/sbin:/usr/local/bin"
  }
}

$resources=hiera_hash('resources', {})
$resources.keys().each |$resourcetype| {
  $resource_entries=$resources[$resourcetype]
  create_resources($resourcetype,$resource_entries)
}

hiera_include('classes')
