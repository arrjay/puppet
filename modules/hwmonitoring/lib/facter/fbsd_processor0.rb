# fbsd_processor0.rb

# make processor0 up for FreeBSD :/
Facter.add("processor0") do
  setcode do
  confine :operatingsystem => %{FreeBSD}
  confine :hardwareisa => %{amd64}
    Facter::Util::Resolution.exec('/sbin/sysctl -n hw.model').chomp
  end
end
