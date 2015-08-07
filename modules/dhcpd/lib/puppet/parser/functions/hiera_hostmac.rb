module Puppet::Parser::Functions
  newfunction(:hiera_hostmac, :type => :rvalue) do |args|
    fqdn = args[0]
    fakescope = { '::fqdn' => args [0] }
    hieraconf_file = lookupvar('::settings::hiera_config')
    hiera2 = Hiera.new(:config => hieraconf_file)
    hiera2.lookup('macaddr', nil, fakescope)
  end
end
