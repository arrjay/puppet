# ups.rb

# if no upsen, return nothing
# if 1 ups, return that serial
# if more than 1 ups, return a comma separated list of serials

devfs_usb = '/sys/bus/usb/devices'
usbconfig = '/usr/sbin/usbconfig'

usblist = []
ugens   = []
usbdevs = []

usb_serialnrs = []

Facter.add("ups") do
  setcode do
    # do we have sysfs usb devices at all?
    if FileTest.directory?(devfs_usb)
      # loop on devices we find
      Dir.foreach(devfs_usb) do |dent|
        # does the device *have* a vendor?
        if FileTest.exists?("#{devfs_usb}/#{dent}/idVendor")
          # does the vendor match one of the vendors we know?
          if File.read("#{devfs_usb}/#{dent}/idVendor") =~ /^051d$/
            # does the product match one of the products we know?
            if File.read("#{devfs_usb}/#{dent}/idProduct") =~ /^0002|0003$/
              # Great! Get the serial number. Eat all whitespace.
              usb_serialnrs.push(File.read("#{devfs_usb}/#{dent}/serial").gsub(/\s+/,""))
            end
          end
        end
      end
    end
    if FileTest.executable?(usbconfig)
      IO.popen(usbconfig).each do |line|
        usblist << line.chomp
      end
      usblist.each do |usbdev|
        # find an ups, get a serial #
        if usbdev =~ /American Power Conversion>/
          ugen = usbdev.scan(/.*:/)
          ugen = ugen[0].chop
          ugens.push(ugen)
          IO.popen("#{usbconfig} -d #{ugen} dump_device_desc").each do |line|
            if line =~ /iSerialNumber/
              match = line.scan(/<.*>/)
              sr = match[0].chop
              serial = sr[1, sr.length - 1].strip
              usb_serialnrs.push(serial)
            end
          end
        end
      end
    end
    # flatten the array now.
    usb_serialnrs.join(",")
  end
end

Facter.add("nutusbdevs") do
  confine :operatingsystem => %{FreeBSD}
  setcode do
    res = []
    targ = ''
    usbdevs = ugens.map{ |ugen| "/dev/#{ugen}" }
    usbdevs.each do |link|
      targ = File.readlink(link)
    end
    res.push(targ)
    res = res.map{ |dev| "/dev/#{dev}" }
    res.join(",")
  end
end
