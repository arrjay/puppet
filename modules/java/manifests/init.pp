class java {
  case $::operatingsystem {
    'FreeBSD': {
      package { [
        "x11/xproto",
        "x11/xextproto",
        "x11/xbitmaps",
        "x11/renderproto",
        "x11/recordproto",
        "x11/printproto",
        "x11/libXdmcp",
        "x11/libXau",
        "x11/libICE",
        "x11/libSM",
        "x11/kbproto",
        "x11/inputproto",
        "x11/fixesproto",
        "textproc/expat2",
        "print/freetype2",
        "x11-fonts/fontconfig",
        "x11-fonts/dejavu",
        "java/javavmwrapper",
        "java/java-zoneinfo",
        "graphics/png",
        "graphics/jpeg",
        "devel/pkgconf",
        "devel/libpthread-stubs",
        "converters/libiconv",
        "textproc/libxml2",
        "x11/libxcb",
        "x11/libX11",
        "x11/libXrender",
        "x11-fonts/libXft",
        "x11/libXfixes",
        "x11/libXext",
        "x11/libXi",
        "x11/libXtst",
        "x11/libXp",
        "x11-toolkits/libXt",
        "x11-toolkits/libXmu",
        "x11/libXpm",
        "x11-toolkits/libXaw",
        "x11-toolkits/open-motif",
        "archivers/zip",
        "archivers/unzip",
        "print/cups-client",
        "misc/compat8x",
        ]:
        ensure => installed
      } -> package { "java/openjdk6-jre": ensure => installed, provider => 'portupgrade', }
      include java::freebsd
    }
  }
}
