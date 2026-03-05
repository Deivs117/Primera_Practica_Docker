# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-22.04"

  # ── servidorUbuntu ──────────────────────────────────────────────────────────
  config.vm.define "servidorUbuntu" do |server|
    server.vm.hostname = "servidorUbuntu"
    server.vm.network "private_network", ip: "192.168.100.5"

    server.vm.provider "virtualbox" do |vb|
      vb.name   = "servidorUbuntu"
      vb.memory = "2048"
      vb.cpus   = 2
    end

    server.vm.provision "shell", path: "provision/install_docker.sh"
  end

  # ── clienteUbuntu ───────────────────────────────────────────────────────────
  config.vm.define "clienteUbuntu" do |client|
    client.vm.hostname = "clienteUbuntu"
    client.vm.network "private_network", ip: "192.168.100.4"

    client.vm.provider "virtualbox" do |vb|
      vb.name   = "clienteUbuntu"
      vb.memory = "2048"
      vb.cpus   = 2
    end

    client.vm.provision "shell", path: "provision/install_docker.sh"
  end
end
