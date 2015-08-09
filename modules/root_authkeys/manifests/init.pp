# stomp on .ssh/authorized_keys for the root user
class root_authkeys (
  $roothome = '/root',
) {
  file{"$roothome/.ssh":
    ensure	=> directory,
    mode	=> '0700',
  }

  file{"$roothome/.ssh/authorized_keys":
    ensure	=> present,
    mode	=> '0644',
    source	=> 'puppet:///modules/root_authkeys/authorized_keys',
  }
}
