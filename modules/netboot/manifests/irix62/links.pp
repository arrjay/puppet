class netboot::irix62::links(
) {
  include netboot::irix_common
  include stdlib

  # this is not a template, but it's the only sane way to *find* the file
  # unless you really truly want it in your puppet code...
  $linklist = parsejson(template('netboot/irix62/links.json.erb'))

  # handle extensions...
  define sublink(
    $object = $title,
    $target,
  ) {
    file{"$netboot::irix_common::mount/6.2/$object":
      ensure => symlink,
      target => "../$target/$object",
    }
  }

  # handle files here
  define mylink(
    $object = $title,
    $target,
    $exts = ['.idb', '.man', '.sw'], # set this to not-an-array to get no-ops
  ) {
    file{"$netboot::irix_common::mount/6.2/$object":
      ensure => symlink,
      target => "../$target/$object",
    }

    if is_array($exts) {
      $link_targets = netboot_ext_map($exts,$object)
      netboot::irix62::links::sublink{$link_targets: target => $target }
    }
  }

  # workin' on the link farm...
  create_resources( mylink, $linklist )
}
