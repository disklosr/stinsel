# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "bento/ubuntu-20.04"
  config.vm.network "private_network", ip: "192.168.33.10"
  config.vm.provider "virtualbox" do |vb|
     vb.memory = "512"
  end


config.vm.provision "shell", inline: <<-SHELL
  password=vagrant
  sudo usermod -p `openssl passwd -1  -salt 5RPVAd $password` root
  echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
  systemctl restart sshd
SHELL

end
