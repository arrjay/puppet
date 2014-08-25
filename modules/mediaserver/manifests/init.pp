class mediaserver (
  #$services     = hiera('mediaserver::services'),
  $mtd_config   = hiera('mediaserver::mt_daapd_config'),
  $mtd_adminpw  = hiera('mediaserver::mt_daapd_adminpw'),
  $daap_port    = hiera('mediaserver::daap_port'),
  $mtd_webroot  = hiera('mediaserver::mt_daapd_webdir'),
  $mtd_dbroot   = hiera('mediaserver::mt_daapd_dbdir'),
  $mtd_ssc      = hiera('mediaserver::mt_daapd_sscprog'),
  $rescan       = hiera('mediaserver::rescan_interval'),
  $mtd_plugdir  = hiera('mediaserver::mt_daapd_plugdir'),
  $daapd_user   = hiera('mediaserver::mt_daapd_user'),
  $ssc_codecs   = hiera('mediaserver::daapd_ssc_codecs',undef),
  $daapd_exts   = hiera('mediaserver::daapd_extensions','.mp3,.m4a,.m4p'),
  $daapd_dblvl  = hiera('mediaserver::daapd_debuglevel','1'),
  $daapd_scan   = hiera('mediaserver::daapd_scan_without_clients',true),
  $daapd_sctyp  = hiera('mediaserver::daapd_scan_type','2'),
  $daapd_comp   = hiera('mediaserver::daapd_xfr_compression',true),
  $music_root = hiera('mediaserver::music_root'),
) {
  case $::osfamily {
    'RedHat' : {
      package{'mt-daapd': ensure => installed}
    }
  }
  include mediaserver::core

  file{$mtd_config:
    owner   => root,
    group   => 0,
    mode    => 0644,
    content => template('mediaserver/mt-daapd.conf.erb'),
  }

  exec{"/bin/mkdir -p $mtd_dbroot":
    creates => "$mtd_dbroot",
    before  => File[$mtd_dbroot],
  }

  file{$mtd_dbroot:
    owner   => $daapd_user,
  }

}
