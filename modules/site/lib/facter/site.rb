require 'facter'
require 'ipaddr'

Facter.add("site") do
  setcode do
    begin
      interfaces = Facter.value(:interfaces).split(',')
      site = nil
      produxi = IPAddr.new('172.16.128.0/24')
      chaos = IPAddr.new('10.100.252.0/24')
        interfaces.each do |iface|
          next unless (address = Facter.value("ipaddress_#{iface}"))
          site = 'produxi' if produxi.include?(address)
          site = 'chaos' if chaos.include?(address)
        end
      site
    end
  end
end
