# work around the stupidity in FreeBSD's package provider
if $::operatingsystem == 'FreeBSD' {
  $_sys = downcase($::kernelrelease)
  # fix the fucking package path
  Package { source => "ftp://ftp.freebsd.org/pub/FreeBSD/ports/$::architecture/packages-$_sys/Latest" }
}

hiera_include('classes')
