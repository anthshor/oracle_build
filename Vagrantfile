# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "anthshor/OracleLinux66"
  config.vm.synced_folder "~/Dropbox/Hashicorp/Vagrant/software", "/u01/software", create: true
  config.vm.network :private_network, type: "dhcp"
  config.vm.provision "shell",  path: "provision.sh"
end
