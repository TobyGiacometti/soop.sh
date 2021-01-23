$memory = 512

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-18.04"
  config.vm.provider "virtualbox" do |vm|
    vm.memory = $memory
  end
  config.vm.provider "vmware_desktop" do |vm|
    vm.vmx["memsize"] = $memory.to_s
  end
  config.vm.provider "parallels" do |vm|
    vm.memory = $memory
  end
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.synced_folder ".", "/mnt/project"
  config.vm.provision "shell" do |sh|
    sh.inline = "/mnt/project/sbin/provision"
    sh.privileged = false
  end
end
