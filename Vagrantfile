# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "generic/debian9"
  config.vm.box_check_update = false
  config.vm.synced_folder ".", "/home/src"
  config.vm.provision :shell, path: "bootstrap.sh"
end
