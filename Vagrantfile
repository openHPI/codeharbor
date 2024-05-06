# frozen_string_literal: true

# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = 'ubuntu/jammy64'
  config.vm.provider 'virtualbox' do |v|
    v.memory = 2048
    v.cpus = 2
  end

  # CodeHarbor Rails app
  config.vm.network 'forwarded_port',
    host_ip: ENV.fetch('LISTEN_ADDRESS', '127.0.0.1'),
    host: 7500,
    guest: 7500

  # Webpack Dev Server
  config.vm.network 'forwarded_port',
    host_ip: ENV.fetch('LISTEN_ADDRESS', '127.0.0.1'),
    host: 3045,
    guest: 3045

  config.vm.synced_folder '.', '/home/vagrant/codeharbor'
  config.vm.provision 'shell', path: 'provision/provision.vagrant.sh', privileged: false
end
