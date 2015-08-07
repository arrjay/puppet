module Puppet::Parser::Functions
  newfunction(:hiera_hostdata, :type => :rvalue) do |args|
    fqdn = args.shift
    keys = args.shift
    returns = {}
    fakescope = { '::fqdn' => fqdn }
    hieraconf_file = lookupvar('::settings::hiera_config')
    hiera2 = Hiera.new(:config => hieraconf_file)
    keys.each do |key|
      returns[key] = hiera2.lookup(key, nil, fakescope)
    end
    returns
  end
end
