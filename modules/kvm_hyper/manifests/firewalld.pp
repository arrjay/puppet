class kvm_hyper::firewalld {
  class {'firewalld::direct':
    passthroughs => [{
      ipv   => 'eb',
      args  => '-t filter -A FORWARD --logical-out vmm -j DROP',
    }],
  }
}
