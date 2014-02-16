class phpstack (
) {
  # install the php stack + modules. this is mostly to document the fight against freebsd pdflib :(
  case $::operatingsystem {
    'FreeBSD': {
      # pdflib prereqs
      #package {[
      #  "devel/gmake",
      #]: ensure => installed } ~> package{"print/pdflib": ensure => installed, provider => 'portupgrade'} ~> package{[
      package{"print/pdflib": ensure => installed, provider => 'portupgrade'} ~> package{[
        # other php crap - notable that piwigo will consume these deps :)
        "lang/php5",
        "textproc/php5-ctype",
        "textproc/php5-xmlwriter",
        "textproc/php5-xml",
        "textproc/php5-simplexml",
        "textproc/php5-xmlreader",
        "textproc/php5-dom",
        "converters/php5-mbstring",
        "converters/php5-iconv",
        "www/php5-session",
        "devel/php5-gettext",
        "devel/php5-tokenizer",
        "devel/php5-json",
        "net/php5-sockets",
        "archivers/php5-zlib",
        "sysutils/php5-posix",
        "databases/php5-pdo",
        "databases/php5-mysqli",
        "databases/php5-mysql",
        "security/php5-openssl",
        "security/php5-mcrypt",
        "security/php5-hash",
        "security/php5-filter",
        "print/pecl-pdflib",
        "graphics/php5-exif",
        "graphics/php5-gd",
        "misc/php5-calendar",
      ]: ensure => installed }
      }
  }
}
