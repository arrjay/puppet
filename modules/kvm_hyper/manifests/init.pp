# configure a KVM/libvirt hypervisor. probably full of c7-isms.
class kvm_hyper (
) {

  case $::osfamily {
    'RedHat': {
      ensure_packages(['bridge-utils'])
      $br_deps = [Package['bridge-utils']]
    }
  }

  # build the vmm interface here
  network::bridge::static { 'vmm':
    ensure	=> 'up',
    ipaddress	=> '192.168.169.254',
    netmask	=> '255.255.255.0',
    stp		=> false,
    delay	=> '0',
    ipv6init	=> false,
    require	=> $br_deps,
  }

  # install dnsmasq
  ensure_packages(['dnsmasq'])

  service{'dnsmasq': require => Package['dnsmasq'], enable => true}

  file{'/etc/dnsmasq.conf':
    ensure	=> present,
    content	=> template('kvm_hyper/dnsmasq.conf.erb'),
    require	=> Package['dnsmasq'],
    notify	=> Service['dnsmasq'],
  }
}
