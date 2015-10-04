define netboot::bootparams(
  $params,
  $hostname = $title,
) {
  include bootparams

  #$shorthost = inline_template('<%= f = String.new(str=@host) ; h = f.split(".")[0] ; h -%>')

  concat::fragment{"bootparams - $hostip":
    target  => 'bootparams',
    content => "$hostname $params\n",
  }
}
