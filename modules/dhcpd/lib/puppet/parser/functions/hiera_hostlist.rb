module Puppet::Parser::Functions
  newfunction(:hiera_hostlist, :type => :rvalue) do |args|
    searchdirs = []
    hosts = []
    hieraconf_file = lookupvar('::settings::hiera_config')
    hieraconf = YAML::load(File.open(hieraconf_file))
    hieraconf[:backends].each do |backend|
      if hieraconf[backend.to_sym][:datadir]
        searchdirs.push(hieraconf[backend.to_sym][:datadir])
      end
    end
    # FIXME - allow j.hack to be something else
    searchdirs.map! {|dir| dir << "/host/*.j.hack.yaml"}
    searchdirs.each do |dir|
      files = Dir.glob(dir)
      files.map! {|file| file.sub!(/^.*\/host\//,'') }
      files.map! {|file| file.sub!(/\.yaml$/,'') }
      hosts.concat(files)
    end
    res = hosts.uniq
  end
end
