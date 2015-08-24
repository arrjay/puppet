define netboot::bootparams(
  $params,
  $host = $title,
) {
  include bootparams

  $shorthost = inline_template('<%= f = String.new(str=@host) ; h = f.split(".")[0] ; h -%>')

  concat::fragment{"bootparams - $shorthost":
    target  => 'bootparams',
    content => "$shorthost $params\n",
  }
}
