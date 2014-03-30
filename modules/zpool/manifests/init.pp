class zpool (
  $pools = hiera('zpools'),
  $noop  = hiera('zpool::noop',true),
) {
  $defaults = { noop => $noop }
  # just a basic class around the puppet zpool objects, so we can build from a base.
  create_resources( zpool, $pools, $defaults )
}
