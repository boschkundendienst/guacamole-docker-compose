# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version ">= 1.6.2"

Vagrant.configure("2") do |config|

    config.vm.provider :virtualbox do |v, override|
        #v.gui = true
        v.customize ["modifyvm", :id, "--memory", 2048]
        v.customize ["modifyvm", :id, "--cpus", 2]
        v.customize ["modifyvm", :id, "--vram", 128]
        v.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
        v.customize ["setextradata", "global", "GUI/SuppressMessages", "all" ]
    end

    #
    # WFH VM
    #

    config.vm.define "wfh" do |wfh|
      wfh.vm.box = "ubuntu/xenial64"

      wfh.vm.network :forwarded_port, guest: 443, host: 443, id: "https-traefik"
      wfh.vm.network :forwarded_port, guest: 8088, host: 8080, id: "dashboard-traefik"
      wfh.vm.network :forwarded_port, guest: 8081, host: 8081, id: "http-guacamole"

      wfh.vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, "--memory", 2048]
        vb.customize ["modifyvm", :id, "--cpus", 2]
      end

      wfh.vm.provision "copy_install_script", type: "file", source: "./install.sh", destination: "/tmp/install.sh"      

      wfh.vm.provision "shell_prepare_controller", type: "shell", inline: <<-SHELL
        /tmp/install.sh
        rsync -a /vagrant/ /srv/workfromhome-with-docker/
      SHELL


    end


end