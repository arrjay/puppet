class netboot::ip2x_common (
) {
  # SGI IP22 machines often try to treat UDP port ranges as a signed integer, so...
  class{"tuning::freebsd": portrange_last => '32767'}
}
