# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

current_dir = File.dirname(File.expand_path(__FILE__))
file        = YAML.load_file("#{current_dir}/config.yaml")
boxes       = file['config']['boxes']

VAGRANTFILE_API_VERSION = "2"

require File.dirname(__FILE__) + "/manifests/dependency_manager.rb"

check_plugins ["vagrant-vbguest"]

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    config.vm.box   = "debian/stretch64"

    boxes.each do |box_config|

        box_name    = file['config']['prefix'] + '.' + box_config['name']
        config.vm.define box_name do |box|
	    box.vm.network "public_network", ip: box_config['public_ip'], bridge: "igor"
            box.vm.network "forwarded_port", guest: 80, host: 8080, auto_correct: true
            box.vm.network "forwarded_port", guest: 3000, host: 3000, auto_correct: true
            box.vm.network "forwarded_port", guest: 8025, host: 8025, auto_correct: true
            box.vm.network "forwarded_port", guest: 8081, host: 8081, auto_correct: true
	    box.vm.network "forwarded_port", guest: 6379, host: box_config['ports']['redis'], auto_correct: true
	    box.vm.network "forwarded_port", guest: 3306, host: box_config['ports']['mariadb'], auto_correct: true
	    for port in box_config['ports']['elastic']
	    end
            box.vm.hostname = box_name
            box.vm.synced_folder box_config['laravel_folder'], "/home/vagrant/www/", id: "www",
		        owner: 'vagrant',
                group: 'www-data',
                mount_options: ["dmode=775,fmode=664"]

            box.vm.provider "virtualbox" do |vb|
       	        vb.name = box_name.sub! ".", "-"
                vb.customize ["modifyvm", :id, "--memory", file['config']['ram']]
                vb.customize ["modifyvm", :id, "--cpuexecutioncap", file['config']['cpu']]
		vb.customize ["modifyvm", :id, "--nictype1", "Am79C973"]
		vb.customize ["modifyvm", :id, "--nicpromisc1", "allow-all"]
		vb.customize ["modifyvm", :id, "--nictype2", "Am79C973"]
		vb.customize ["modifyvm", :id, "--nicpromisc2", "allow-all"]
            end
        end
    end
            
    config.vm.provision "shell", path: "manifests/puppet.sh"
    config.vm.provision "shell", path: "manifests/repository.sh"
    config.vm.provision "puppet" do |puppet|
       puppet.environment = 'development'
       puppet.environment_path = 'puppet'
       puppet.hiera_config_path = "puppet/hiera.yaml"
       puppet.working_directory = '/tmp/vagrant-puppet'
    end
    config.vm.provision "shell", path: "manifests/ssh.sh", args: [file['config']['gitlab_private_token']]
end

