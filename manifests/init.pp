# common things for our vm servers (be they Xen, Virtualbox, or KVM)
class vmserver (
  $packages = hiera('vmserver::packages')
) {
  include resolvconf
  package{$packages: ensure => installed}
}
