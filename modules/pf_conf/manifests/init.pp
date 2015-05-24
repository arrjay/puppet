# drop a pf.conf file, reload pf services
class pf_conf (
  $source,
  $keys		= {},
) {
  file{'/etc/pf.conf':
    ensure	=> present,
    mode	=> '0600',
    owner	=> 0,
    content	=> template("pf_conf/$source.erb"),
    notify	=> Exec["pfctl -f /etc/pf.conf"],
  }
  exec{"pfctl -f /etc/pf.conf":
    refreshonly	=> true,
  }
}
