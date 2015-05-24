# common things for our vm servers (be they Xen, Virtualbox, or KVM)
class vmserver (
  $packages = ['dnsmasq'],
  $dnsmasq_conf = hiera('dnsmasq::configfile'),
  $dnsmasq_svcname = 'dnsmasq',
) {
  #include resolvconf
  package{$packages: ensure => installed}
  file{$dnsmasq_conf:
    owner	=> root,
    group	=> 0,
    mode	=> 0644,
    ensure	=> present,
    content	=> template("vmserver/dnsmasq.conf.erb"),
    notify	=> Exec["service $dnsmasq_svcname restart"],
  }
  exec{"service $dnsmasq_svcname restart":
    refreshonly => true,
  }
}
