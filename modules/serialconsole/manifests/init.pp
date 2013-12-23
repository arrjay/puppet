class serialconsole {
  $consoleport  = hiera('serialconsole::port',0)
  $consolespeed = hiera("serialconsole::speed",9600) 
  $consoletype  = hiera("serialconsole::type","vt100")
  # note that if you *move* a console port, this class leaves it to you to unconfigure. *shrug*
  # attempt to set up a serial console. defaults to port 0, but can override in hiera.
  # we actually do this regardless of virtualization setup, since we can often talk to a hypervisor this way.
  case $::operatingsystem {
    'FreeBSD': {
      $getty = hiera("serialconsole::port$consoleport_getty","/usr/libexec/getty")
      case $consoleport {
        '0': {
          $consoletty = 'ttyu0'
        }
      }
      # we could touch /boot.config, but the docs are unclear as to where that *is*, especially with ZFS root.
      # twiddle /etc/ttys
      # we need to get a line to eventually match something like 'ttyu0 "/usr/libexec/getty std.9600" vt100 on secure'
      # simplest case - no tty line in ttys
      exec {"adding $consoletty to /etc/ttys":
        unless  => "/usr/bin/grep -q ^$consoletty /etc/ttys",
        before  => [ Exec["setting $consoletty speed: $consolespeed"], Exec["setting $consoletty type: $consoletype"], ],
        notify  => Exec["reconfigure init: ttys"],
        command => "/bin/echo '${consoletty} \"/usr/libexec/getty std.$consolespeed\" $consoletype on secure' >> '/etc/ttys'",
      }
      # change the speed now
      exec {"setting $consoletty speed: $consolespeed":
        command  => "temp=\$(/usr/bin/mktemp) && /usr/bin/awk '{if (\$1 == \"$consoletty\"){print \$1,\"\\\"/usr/libexec/getty\",\"std.$consolespeed\\\"\",\$4,\$5,\$6}else{print \$0}}' /etc/ttys > \$temp && mv \$temp /etc/ttys",
        unless   => "/usr/bin/awk '\$1 == \"$consoletty\" {split(\$3,s,\".\");print substr(s[2],0,length(s[2]-1))}' /etc/ttys|grep -qFx $consolespeed",
        before   => Exec["enabling tty: $consoletty"],
        notify  => Exec["reconfigure init: ttys"],
        provider => "shell",
      }
      exec {"setting $consoletty type: $consoletype":
        command  => "temp=\$(/usr/bin/mktemp) && /usr/bin/awk '{if (\$1 ==\"$consoletty\"){print \$1,\$2,\$3,\"$consoletype\",\$5,\$6}else{print \$0}}' /etc/ttys > \$temp && mv \$temp /etc/ttys",
        unless   => "/usr/bin/awk '\$1 == \"$consoletty\" {print \$4}' /etc/ttys|grep -qFx $consoletype",
        before   => Exec["enabling tty: $consoletty"],
        notify  => Exec["reconfigure init: ttys"],
        provider => "shell",
      }
      exec {"enabling tty: $consoletty":
        command  => "temp=\$(/usr/bin/mktemp) && /usr/bin/awk '{if (\$1 == \"$consoletty\"){print \$1,\$2,\$3,\$4,\"on\",\$6}else{print \$0}}' /etc/ttys > \$temp && mv \$temp /etc/ttys",
        unless   => "/usr/bin/awk '\$1 == \"$consoletty\" {print \$5}' /etc/ttys|grep -qFx on",
        notify  => Exec["reconfigure init: ttys"],
        provider => "shell",
      }
      exec {"reconfigure init: ttys":
        refreshonly => true,
        command     => "/bin/kill -HUP 1",
      }
      # twiddle /boot/loader.conf
      augeas { "loader.conf: console setup":
        changes => [
          "set /files/boot/loader.conf/boot_multicons YES",
          "set /files/boot/loader.conf/boot_serial YES",
          "set /files/boot/loader.conf/comconsole_speed $consolespeed",
          "set /files/boot/loader.conf/console comconsole,vidconsole",
        ],
      }
    }
  }
}
