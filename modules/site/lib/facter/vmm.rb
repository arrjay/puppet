require 'facter'
require 'ipaddr'

Facter.add("vmm") do
  setcode do
    if Facter.is_virtual
      begin
      vmm = nil
      vmm_net = IPAddr.new('192.168.169.0/24')
      interfaces = Facter.value(:interfaces).split(',')
        interfaces.each do |iface|
          next unless (address = Facter.value("ipaddress_#{iface}"))
          vmm = 'true' if vmm_net.include?(address)
        end
      end
      vmm
    end
  end
end
