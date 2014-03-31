define bootparamd::line (
  $content,
  $host = $title,
) {
  concat::fragment{"bootparamd line: $host":
    target	=> $bootparamd::config,
    content	=> $content,
  }
}
