# -*- mode: ruby -*-
# vi: set ft=ruby :

# all helper functions from https://github.com/NextThingCo/CHIP-SDK/pull/15
def which(cmd)
  exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
  ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
    exts.each { |ext|
      exe = File.join(path, "#{cmd}#{ext}")
      return exe if File.executable?(exe) && !File.directory?(exe)
    }
  end
  return nil
end

# usbfilter_exists and better_usbfilter_add originally part of a pull request
# https://github.com/mitchellh/vagrant/issues/5774
def usbfilter_exists(vendor_id, product_id)
  # Determine if a usbfilter with the provided Vendor/Product ID combination
  # already exists on this VM.
  # NOTE: The "machinereadable" output for usbfilters is more
  #       complicated to work with (due to variable names including
  #       the numeric filter index) so we don't use it here.
  #
  machine_id_filepath = File.join(".vagrant", "machines", "default", "virtualbox", "id")

  if not File.exists? machine_id_filepath
    # VM hasn't been created yet.
    return false
  end

  machine_id = File.read(machine_id_filepath)

  vm_info = `VBoxManage showvminfo #{machine_id}`
  filter_match = "VendorId:         #{vendor_id}\nProductId:        #{product_id}\n"

  return vm_info.include? filter_match
end

def better_usbfilter_add(vb, vendor_id, product_id, filter_name)
  # This is a workaround for the fact VirtualBox doesn't provide
  # a way for preventing duplicate USB filters from being added.
  #
  # TODO: Implement this in a way that it doesn't get run multiple
  #       times on each Vagrantfile parsing.
  if not usbfilter_exists(vendor_id, product_id)
    vb.customize ["usbfilter", "add", "0",
                  "--target", :id,
                  "--name", filter_name,
                  "--vendorid", vendor_id,
                  "--productid", product_id
                  ]
  end
end

Vagrant.configure(2) do |config|
  config.vm.box = "boxcutter/ubuntu1404-desktop"
  config.vm.provider "virtualbox" do |v|
    v.gui = true
    v.customize ['modifyvm', :id, '--usb', 'on']
    v.customize ['modifyvm', :id, '--usbxhci', 'on']
    better_usbfilter_add(v, "05ac", "8406", "Apple integrated SD card reader")
  end
  config.vm.provision "shell", inline: <<-SHELL
    sudo apt-get update
    sudo apt-get install -y curl wget unzip pv
  SHELL
end
