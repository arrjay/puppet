module Puppet::Parser::Functions
  newfunction(:ip2hex, :type => :rvalue) do |args|
    ip = args[0]
    iph = []
    ipoct = ip.split('.')
    iph[0] = "%02X" % ipoct[0]
    iph[1] = "%02X" % ipoct[1]
    iph[2] = "%02X" % ipoct[2]
    iph[3] = "%02X" % ipoct[3]
    iph.join()
  end
end
