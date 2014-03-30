class zpool (
  $pools = hiera('zpools'),
) {
  # just a basic class around the puppet zpool objects, so we can build from a base.
  create_resources( zpool, $pools )
}
