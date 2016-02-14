# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "boxcutter/ubuntu1404-desktop"

   config.vm.provider "vmware_fusion" do |v|
     v.gui = true
     v.vmx["usb.present"] = "TRUE"
     v.vmx["usb.pcislotnumber"] = "32"
     v.vmx["usb:0.present"] = "TRUE"
     v.vmx["usb:0.deviceType"] = "hid"
     v.vmx["usb:0.port"] = "0"
     v.vmx["usb:0.parent"] = "-1"
     v.vmx["usb:1.speed"] = "2"
     v.vmx["usb:1.present"] = "TRUE"
     v.vmx["usb:1.deviceType"] = "hub"
     v.vmx["usb:1.port"] = "1"
     v.vmx["usb:1.parent"] = "-1"
   end
  config.vm.provision "shell", inline: <<-SHELL
    sudo apt-get update
    sudo apt-get install -y curl wget unzip pv
  SHELL
end
