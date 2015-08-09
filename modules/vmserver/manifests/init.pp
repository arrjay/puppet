# common things for our vm servers (be they Xen, Virtualbox, or KVM)
class vmserver (
  $packages = ['dnsmasq'],
  $dnsmasq_conf = '/etc/dnsmasq.conf',
  $dnsmasq_svcname = 'dnsmasq',
) {
  #include resolvconf
  package{$packages: ensure => installed}
  file{$dnsmasq_conf:
    ensure	=> present,
    content	=> template("vmserver/dnsmasq.conf.erb"),
    notify	=> Exec["service $dnsmasq_svcname restart"],
  }
  exec{"service $dnsmasq_svcname restart":
    refreshonly => true,
  }
}
