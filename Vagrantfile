# frozen_string_literal: true

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

  config.vm.synced_folder '../codeharbor', '/home/vagrant/codeharbor'
  config.vm.provision 'shell', path: 'provision.sh', privileged: false
end
