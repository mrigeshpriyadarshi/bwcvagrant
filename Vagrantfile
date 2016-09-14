# -*- mode: ruby -*-
# vi: set ft=ruby :

hostname   = ENV['HOSTNAME'] ? ENV['HOSTNAME'] : 'bwcvagrant'
box        = ENV['BOX'] ? ENV['BOX'] : 'bento/ubuntu-14.04'
st2user    = ENV['ST2USER'] ? ENV['ST2USER']: 'st2admin'
st2passwd  = ENV['ST2PASSWORD'] ? ENV['ST2PASSWORD'] : 'Ch@ngeMe'
bwc_license  = ENV['BWC_LICENSE'] ? ENV['BWC_LICENSE'] : 'bwc_license_key'
bwc_suites = ENV['BWC_SUITES'] ? ENV['BWC_SUITES'] : 'abc'

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.define "bwc" do |bwc|
    # Box details
    bwc.vm.box = "#{box}"
    bwc.vm.hostname = "#{hostname}"

    # Box Specifications
    bwc.vm.provider :virtualbox do |vb|
      vb.name = "#{hostname}"
      vb.memory = 1028
      vb.cpus = 2
    end

    # NFS-synced directory for pack development
    # Change "/path/to/directory/on/host" to point to existing directory on your laptop/host and uncomment:
    # config.vm.synced_folder "/path/to/directory/on/host", "/opt/stackstorm/packs", :nfs => true, :mount_options => ['nfsvers=3']

    # Configure a private network
    bwc.vm.network :private_network, ip: "192.168.16.21"

    # Public (bridged) network may come handy for external access to VM (e.g. sensor development)
    # See https://www.vagrantup.com/docs/networking/public_network.html
    # bwc.vm.network "public_network", bridge: 'en0: Wi-Fi (AirPort)'

    # Start shell provisioning.
    bwc.vm.provision "shell" do |s|
      s.path = "scripts/install_bwc.sh"
      s.args   = "#{st2user} #{st2passwd} #{bwc_license} #{bwc_suites}"
      s.privileged = false
    end
  end

end
