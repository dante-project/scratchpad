```
How to run this?
First you need to install virtualbox and vagrant, 
after that clone this repository and run vargant up.
> git clone git@github.com:dante-project/scratchpad.git
> vargant up

The bootstrap.sh script will get executed on machines boot 
and install all the tools you need to compile the OS.
It will also run makefiles and output os image in /home/build.

To log into virtual machine run `vagrant ssh`, to exit the VM
run `logout`, to shutdown the machine run `vagrant halt`, and 
finally to terminate use of resources on your machine (including 
virtual machines disks) run `vagrant destroy`.


# Extras
# installing virtualbox and vagrant on Debian 9
add stretch-backports main and contrib to your apt sources
sudo apt install virtualbox
wget https://releases.hashicorp.com/vagrant/2.1.1/vagrant_2.1.1_x86_64.deb
sudo dpkg -i vagrant_2.1.1_x86_64.deb
```
