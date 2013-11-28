class puppetclient (
  $puppetcfg = hiera('puppet::configfile'),
){
  # enable pluginsync
  augeas { "$puppetcfg: enable pluginsync":
    changes => [
      "set /files/$puppetcfg/main/pluginsync true",
    ],
  }
}
