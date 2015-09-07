class kvm_hyper::firewalld {
  class {'firewalld::direct':
    rules => [{
      ipv   => 'eb',
      table => 'filter',
      chain => 'FORWARD',
      args  => '--logical-out vmm -j DROP',
    }],
  }
}
