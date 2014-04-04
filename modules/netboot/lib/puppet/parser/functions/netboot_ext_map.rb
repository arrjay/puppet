module Puppet::Parser::Functions
  newfunction(:netboot_ext_map, :type => :rvalue) do |args|
    extensions = args[0]
    file = args[1]
    extensions.map {|x| x = "#{file}#{x}" }
  end
end
