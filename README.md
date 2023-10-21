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

A bash script (system-uptime-script_new.sh) was written to check the uptime of the servers and keep a report of it on the server. There is an error handling section in the script that enters any error encountered into error log for proper attention. This script reads server ip from a text file (servers.txt)to know the servers to check up. The script has been scheduled in crontab to be running every 12.00am and write to different logs.

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

## Bash Scripts list

- provision_master.sh
- provision_slave.sh
- system-uptime-script_new.sh
  
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

### Server uptime Script - system-uptime-script_new.sh

#!/bin/bash

log_file="/tmp/uptime-report.log"

uptime_file="/tmp/uptime-report.out"

error_file="/tmp/uptime-report-errors.log"

##### Function to log messages with timestamps

log() {

    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" >> "$log_file"
    
}

log "Starting server uptime check..."

##### Read server hostnames or IP addresses from /tmp/servers.txt

upserver=$(for server in $(cat /tmp/servers.txt)

do

    # Use ssh to check the uptime of the server
    
    if ssh "$server" 'uptime' &> /dev/null; then
    
        uptime_output=$(ssh "$server" 'uptime')
        
        echo -n "$(date +'%Y-%m-%d %H:%M:%S') - $server: " >> "$uptime_file"
        
        echo "$uptime_output" | awk '{print $3,$4}' | sed 's/,//' >> "$uptime_file"
        
    else
    
        log "Failed to get uptime for $server."
        
        echo "$(date +'%Y-%m-%d %H:%M:%S') - Failed to get uptime for $server." >> "$error_file"
        
    fi
    
done)

##### Check if any errors occurred

if [ -s "$error_file" ]; then

    log "Errors occurred during uptime checks. See $error_file for details."
    
else

    log "Server uptime check completed successfully."
    
fi

##### Display the uptime report

if [ -s "$uptime_file" ]; then

    column -t < "$uptime_file"
    
else

    log "No servers were reachable or provided uptime information."
    
fi

## Sql Script - To create schoolReg2 table and insert values

CREATE TABLE IF NOT EXISTS schoolReg2 (

  message varchar(255) NOT NULL
  
  ) ENGINE=MyISAM DEFAULT CHARSET=utf8;
  
  INSERT INTO schoolReg2(message) VALUES('You are welcome');
  
  INSERT INTO schoolReg2(message) VALUES('This is good');
  
  INSERT INTO schoolReg2(message) VALUES('Fun all the way')


## Pictorial Proofs of the Project
Find below schrenshots of **vagrant up**, **ssh vagrant@192.168.56.25**, **ansible-playbook lampstack_new.yml** during testing and **apache** page which I edited to include my name in the source file.

#### vagrant up and vagrant ssh master

<img width="960" alt="master_vm_details" src="https://github.com/jidejj/AltSchool_LAMP_Deployment_Project/assets/9843012/fc22e236-1d20-41c0-9742-4dbd095019e2">

#### ssh vagrant@192.168.56.25

<img width="960" alt="slave_vm_details" src="https://github.com/jidejj/AltSchool_LAMP_Deployment_Project/assets/9843012/07795b13-5a3d-4690-8b85-f809538793ad">

#### playbook execution - (ansible-playbook lampstack_new.yml)

<img width="960" alt="screenshot2" src="https://github.com/jidejj/AltSchool_LAMP_Deployment_Project/assets/9843012/1db4ac79-b2fa-4ec3-8c0d-85df36a7fb82">

<img width="960" alt="screenshot3" src="https://github.com/jidejj/AltSchool_LAMP_Deployment_Project/assets/9843012/a231305d-d661-420f-8314-61510fd318bb">

#### Apache Default Page 

<img width="960" alt="screenshot1" src="https://github.com/jidejj/AltSchool_LAMP_Deployment_Project/assets/9843012/a47818fd-fa9b-4bdd-b4e8-4ace4640087f">

#### Servers uptime logs (bash system-uptime-script_new.sh)

<img width="960" alt="servers_uptime_logs" src="https://github.com/jidejj/AltSchool_LAMP_Deployment_Project/assets/9843012/f462dbb1-7f67-47f6-b284-88e6e5418a2e">

#### crontab scheduling

<img width="960" alt="Cron Scheduling" src="https://github.com/jidejj/AltSchool_LAMP_Deployment_Project/assets/9843012/9df9af82-dc28-4776-8d01-7339889709d8">

#### Slave Database Connection and Extraction from schoolReg2 table of altschooldb

<img width="960" alt="Database Connection" src="https://github.com/jidejj/AltSchool_LAMP_Deployment_Project/assets/9843012/b10df0e2-e0f7-4e63-86f0-ced6da28c3a2">


## Resources:

Below are some of the resources used:

<https://medium.com/@melihovv/zero-time-deploy-of-laravel-project-with-ansible-3235816676bb>

<https://www.cherryservers.com/blog/how-to-install-and-setup-postgresql-server-on-ubuntu-20-04>

<https://dev.to/sureshramani/how-to-deploy-laravel-project-with-apache-on-ubuntu-36p3>

<https://docs.ansible.com/>





      
