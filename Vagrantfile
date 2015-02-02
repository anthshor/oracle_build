# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "kikitux/oracle6"

  config.vm.provision "puppet" do |proxy|
    proxy.manifests_path = "manifests"
    proxy.manifest_file = "proxy.pp"
  end
  config.vm.provision "puppet" do |puppet|
    puppet.manifests_path = "manifests"
    puppet.manifest_file = "site.pp"
  end

end
