class mediaserver::forked-daapd (
  $servername = $::hostname,
  $port = 3689,
  $password = undef,
  $podcast_dir = '_PODCASTS',
  $audiobook_dir = '_AUDIOBOOKS',
  $compilations_dir = '_COMPILATIONS',
  $compilation_artist = 'Compilations',
  $artwork_names = [],
  $ignore_filetypes = [ '.db', '.ini', '.flac' ],
  $filescan_disable = false,
  $skip_transcode = [ 'alac', 'mp4a' ],
  $force_transcode = [ 'ogg', 'flac' ],
) {
  # per-os variables
  case $::osfamily {
    'RedHat' : {
      $daapd_config = '/etc/forked-daapd.conf'
      $daap_user = 'forked-daapd'
      $forked_daapd_log = '/var/log/forked-daapd.log'
      $forked_daapd_db = '/var/cache/forked-daapd/songs3.db'
    }
  }

  # per-os initialization
  case $::osfamily {
    'RedHat' : {
      # suck in the repos so the package install has a hope of working
      include rpmrepo::epel
      include rpmrepo::rpmfusion-free-updates
      include rpmrepo::arrjay

      package {'forked-daapd': ensure => 'installed'}
    }
  }

  # common initialization
  include avahi

  file{$daapd_config:
    owner => 'root',
    group => 0,
    mode => '0644',
    content => template('mediaserver/forked-daapd.conf.erb'),
  }
}
