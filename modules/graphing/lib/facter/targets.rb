# targets.rb

# try to figure out what we should be graphing. currently a nasty mess as I guess at rrd graph dirs.

rrd_dirs = ['/var/lib/mrtg', '/var/db/mrtg']

graph_targets = []

Facter.add("graph_targets") do
  setcode do
    rrd_dirs.each do |dir|
    # is this a directory?
     if FileTest.directory?(dir)
       Dir.foreach(dir) do |dent|
         # skip . files
         next if dent =~ /^\./
         # we also dump mrtg *files* in here. only list the directories.
         if FileTest.directory?("#{dir}/#{dent}")
           graph_targets.push(dent)
         end
       end
     end
    end
    # flatten the array for puppet handoff.
    graph_targets.join(",")
  end
end
