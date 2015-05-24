# provide a default path for exec blocks here.
Exec {
  path => $osfamily ? {
    default => "/usr/sbin:/sbin:/usr/bin:/bin:/usr/local/sbin:/usr/local/bin"
  }
}

hiera_include('classes')
