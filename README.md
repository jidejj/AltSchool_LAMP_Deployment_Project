# AltSchool_LAMP_Deployment_Project
This is Altschool second semester Examination Project

## Task
- Automate the provisioning of two Ubuntu-based servers, named "Master" and "Slave", using Vagrant.
- On the Master node, create a bash script to automate the deployment of a LAMP (Linux, Apache, MySQL, PHP) stack.
- This script should clone a PHP application from GitHub, install all necessary packages, and configure Apache web server and MySQL. 
- Ensure the bash script is reusable and readable.

### Using an Ansible playbook:
- Execute the bash script on the Slave node and verify that the PHP application is accessible through the VM's IP address (take screenshot of this as evidence)
- Create a cron job to check the server's uptime every 12 am.

# Solution
Configure vagrantfile to deploy two VMs as showb below in a sample file:

## Vagrantfile

Vagrant.configure("2") do |config|
    
    # Master VM
    config.vm.define "master" do |master|
      master.vm.box = "ubuntu/focal64"
    config.vm.provider :libvirt do |libvirt|
       libvirt.driver = "qemu"
      master.vm.hostname = 'master'
      master.vm.network "private_network", type: "dhcp"
      end
      master.vm.provision "ansible" do |ansible|
        ansible.playbook = "lamp.yml"
      end
    end

    # Slave VM
    config.vm.define "slave" do |slave|
      slave.vm.box = "ubuntu/focal64"
    config.vm.provider :libvirt do |libvirt|
       libvirt.driver = "qemu"
      slave.vm.hostname = 'slave'
      slave.vm.network "private_network", type: "dhcp"
      end
      slave.vm.provision "ansible" do |ansible|
        ansible.playbook = "lamp.yml"
      end
    end
  end
