# common things for our vm servers (be they Xen, Virtualbox, or KVM)
class vmserver (
  $packages = hiera('vmserver::packages'),
  $dnsmasq_conf = hiera('dnsmasq::configfile'),
  $dnsmasq_svcname = hiera('dnsmasq::svcname'),
  $svccmd = hiera('service'),
) {
  include resolvconf
  package{$packages: ensure => installed}
  file{$dnsmasq_conf:
    owner	=> root,
    group	=> 0,
    mode	=> 0644,
    ensure	=> present,
    content	=> template("vmserver/dnsmasq.conf.erb"),
    notify	=> Exec["$svccmd $dnsmasq_svcname restart"],
  }
  exec{"$svccmd $dnsmasq_svcname restart":
    refreshonly => true,
  }
}
