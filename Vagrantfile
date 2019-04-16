# frozen_string_literal: true

Vagrant.configure(2) do |config|
  config.vm.box = 'ubuntu/trusty64'
  config.vm.provider 'virtualbox' do |v|
    config.vm.network 'forwarded_port', guest: 3000, host: 3001
    v.memory = 1024
  end
  # config.vm.network "private_network", ip: "192.168.60.111"
  # config.vm.synced_folder "../data", "/vagrant_data"
  config.vm.provision 'shell', path: 'provision.sh'
end
