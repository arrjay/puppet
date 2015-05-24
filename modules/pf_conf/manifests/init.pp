# drop a pf.conf file, reload pf services
class pf_conf (
  $source
) {
  file{'/etc/pf.conf':
    ensure	=> present,
    mode	=> '0600',
    owner	=> 0,
    source	=> "puppet:///modules/pf_conf/$source",
    notify	=> Exec["pfctl -f /etc/pf.conf"],
  }
  exec{"pfctl -f /etc/pf.conf":
    refreshonly	=> true,
  }
}
