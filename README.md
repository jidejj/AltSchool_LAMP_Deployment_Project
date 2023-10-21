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

## Project Overview
The project is designed to test the concept of **bash scripting**, **vagrantfile** configuration and **ansible playbook** setup. It is meant to prepare fully for Cloud Engineering journey. I used Oracle VM virtuabox in deploying solution to the project given.
Vagrantfile was used to provision two virtual machines which are **master** and **slave**. The provisioning include setting up of dhcp network with port forwarding, assigning of ip and configuration of the vms to meet the needed requirement for the project.

# Solution
Vagrantfile was configured by putting specification as needed including bash script and ansible playbook. Each of the files in vagrantfile and details of vagrantfile can be seen as displayed in the paragraphs below:

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

To execute vagrantfile, the command **vagrant up** was used on the command line in the directory where vagrant was installed. Installation of vagrant on the control machine is a prerequisite for the use of vagrant file. In the case of this project, vagrant was installed on my local machine running windows 10. Details of how to install vagrant can be obtained [here](https://developer.hashicorp.com/vagrant).

Likewise, ansible as a tool for the project was also installed on the master so as to effect proper automates provisioning, configuration management, application deployment and orchestration of slave through master. Details of ansible documentation is available [here](https://www.ansible.com). Ansible playbook used for this project is displayed below:

## Ansible Playbook (lampstack_new.yml)

---
- name: install apache php and mysql
  hosts: 192.168.56.25
  become: true
  become_user: root
  gather_facts: true

  tasks:
     - name: Copy the script to the slave
       copy:
        src: /home/vagrant/provision_slave.sh
        dest: /home/vagrant/provision_slave.sh
        mode: 0755
       become_user: vagrant

     - name: Execute the script on the slave
       shell: /home/vagrant/provision_slave.sh
       become_user: vagrant

     - name: "install apache2"
       package: name=apache2 state=present

    - name: "install apache2 php5"
       package: name=libapache2-mod-php state=present

     - name: "install php-cli"
       package: name=php-cli state=present

     - name: "install php-gd"
       package: name=php-gd state=present

     - name: "install php-mysql"
       package: name=php-mysql state=present

     - name: "install mysqlserver"
       package: name=mysql-server state=present

     - name: Install MySQL
       apt:
        name: mysql-server
        state: present
       
     - name: Copy custom MySQL configuration
       copy:
         src: /home/vagrant/.my.cnf
         dest: /etc/mysql/.my.cnf
       notify: Restart PyMySQL

     - name: Ensure MySQL is started and enabled
       service:
         name: mysql
         state: started
         enabled: yes

     - name: Create a MySQL database
       mysql_db:
         name: altschooldb
         state: present
       become_method: sudo
       become_user: altschool
       become: yes

     - name: Create a MySQL table
       mysql_db:
         name: altschooldb
         state: import
         target: /home/vagrant/dump.sql
       become_user: altschool
       become: yes

     - name: Create a MySQL user
       mysql_user:
         name: altschool
         password: altschool

  handlers:
    - name: Restart PyMySQL
      service:
        name: mysql-server
        state: restarted

## Bash Scripts 

### provision_master.sh

#!/bin/bash

##### Update and upgrade packages
sudo apt-get update
sudo apt-get -y upgrade

##### Install LAMP stack
sudo apt-get install -y apache2 mysql-server php libapache2-mod-php php-mysql

##### Clone the PHP application from GitHub
git clone https://github.com/jidejj/AltSchool_LAMP_Deployment_Project.git /var/www/html

### provision_slave.sh

#!/bin/bash

##### Update and Upgrade packages
sudo apt-get update
sudo apt-get -y upgrade

##### Install Apache, MySQL, PHP, and other necessary packages
sudo apt-get install -y apache2 mysql-server php libapache2-mod-php php-mysql

##### Enable Apache and MySQL services
sudo systemctl enable apache2
sudo systemctl enable mysql

##### Start Apache and MySQL services
sudo systemctl start apache2
sudo systemctl start mysql

## Pictorial Proofs of the Project
Find below schrenshots of **vagrant up**, **ssh vagrant@192.168.56.25**, **ansible-playbook lampstack_new.yml** during testing and **apache** page which I edited to include my name in the source file.

#### vagrant up and vagrant ssh master

<img width="960" alt="master_vm_details" src="https://github.com/jidejj/AltSchool_LAMP_Deployment_Project/assets/9843012/fc22e236-1d20-41c0-9742-4dbd095019e2">

#### ssh vagrant@192.168.56.25

<img width="960" alt="slave_vm_details" src="https://github.com/jidejj/AltSchool_LAMP_Deployment_Project/assets/9843012/07795b13-5a3d-4690-8b85-f809538793ad">

#### playbook execution - lampstack_new.yml

<img width="960" alt="screenshot2" src="https://github.com/jidejj/AltSchool_LAMP_Deployment_Project/assets/9843012/1db4ac79-b2fa-4ec3-8c0d-85df36a7fb82">

<img width="960" alt="screenshot3" src="https://github.com/jidejj/AltSchool_LAMP_Deployment_Project/assets/9843012/a231305d-d661-420f-8314-61510fd318bb">

#### Apache Default Page 

<img width="960" alt="screenshot1" src="https://github.com/jidejj/AltSchool_LAMP_Deployment_Project/assets/9843012/a47818fd-fa9b-4bdd-b4e8-4ace4640087f">



## Resources:

Below are some of the resources used:

<https://medium.com/@melihovv/zero-time-deploy-of-laravel-project-with-ansible-3235816676bb>

<https://www.cherryservers.com/blog/how-to-install-and-setup-postgresql-server-on-ubuntu-20-04>

<https://dev.to/sureshramani/how-to-deploy-laravel-project-with-apache-on-ubuntu-36p3>

<https://docs.ansible.com/>





      
