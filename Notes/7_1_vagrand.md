# Content



## Introduction
  Vagrant is a tool for building and distributing development environments.

Development environments managed by Vagrant can run on local virtualized platforms such as VirtualBox or VMware

Vagrant provides the framework and configuration format to create and manage complete portable development environments. These development environments can live on your computer or in the cloud, and are portable between Windows

Instead of VM box it can used to maintain the VM (as in a different environment)

## [Installation and Commands](https://developer.hashicorp.com/vagrant/tutorials/getting-started/getting-started-install)
Pre-requisite: VM Providers like VirtualBox, etc.

Steps:
1. Create the folder in which vagrant init creates the config file 
2. Initialize the VM instance `vagrant init <box-name>, eg: vagrant init generic/debian11`
3. To run `vagrant up`
4. To enter the VM instance `vagrant ssh` (Authentication can be enabled)
5. To stop the process `vagrant suspend` (saves the state and things created will be gained back when running the process again)

