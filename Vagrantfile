# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
 	config.vm.box = "chef/centos-6.5"

	config.vm.define :mongoStandalone do |server|
		server.vm.box = "chef/centos-6.5"

		server.vm.provider "virtualbox" do |vb|
			vb.name = "mongo-centos"
			vb.memory = 4096
			vb.cpus = 2

			disk = 'disk.vdi'
			vb.customize ["storagectl", :id, "--add", "sata", "--name", "SATA" , "--portcount", 1, "--hostiocache", "on"]
			vb.customize ['createhd', '--filename', disk, '--size', 102400]
			vb.customize ['storageattach', :id, '--storagectl', 'SATA', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', disk]
		end

		## server.vm.network :private_network, ip: "192.168.19.221"
		server.vm.hostname = "mongo-centos"
		server.vm.provision :shell, path: "bootstrap.sh"
		server.vm.network "forwarded_port", guest: 27017, host: 27017
	end
end
