Configuring a Chef Analytics Cluster
====================================

Prerequisities
==============

1. Install [VirtualBox](https://www.virtualbox.org/)
2. Install [Vagrant](https://www.vagrantup.com/)
3. Install [ChefDK](https://downloads.chef.io/chef-dk/)
4. In this directory, run `rake converge`

Once the rake command has completed, you should be able to go to the
[Chef Web UI](https://localhost:4443) and log in with username `analytics` and password `workshop`. 
Once logged in, download a private key for your user by going to FIXME, then copy it to `.chef/analytics.pem` in this directory. Then download a new validator key from FIXME and copy it to `.chef/analytics-validator.pem`. 
You should now be able to successfully run `knife node list` and get an
empty list back.

