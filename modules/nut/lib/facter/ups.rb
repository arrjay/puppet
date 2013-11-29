# ups.rb

# if no upsen, return nothing
# if 1 ups, return that serial
# if more than 1 ups, return a comma separated list of serials

devfs_usb = '/sys/bus/usb/devices'

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
    # flatten the array now.
    usb_serialnrs.join(",")
  end
end
