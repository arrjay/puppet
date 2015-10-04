class rpmrepo::arrjay_rpc (
) {
  include rpmrepo::arrjay

  yumrepo {'arrjay-rpc':
    enabled  => '1',
    gpgcheck => '1',
    baseurl  => 'http://arrjay.github.io/rpm/el$releasever-rpcbind/$basearch',
  }
}
