# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "kikitux/oracle7"

  config.vm.provision "puppet" do |proxy|
    proxy.manifest_file = "proxy.pp"
  end
  config.vm.provision "puppet" do |puppet|
    puppet.manifest_file = "site.pp"
  end

end
