Configuring a Chef Analytics Cluster
====================================

Prerequisities
==============

1. Install [VirtualBox](https://www.virtualbox.org/)
2. Install [Vagrant](https://www.vagrantup.com/)
3. Install [ChefDK](https://downloads.chef.io/chef-dk/)
4. In this directory, run `rake converge`

Once the rake command has completed, you should be able to go to the
[Chef Web UI](https://192.168.56.100) and log in with username `analytics` and password `workshop`. 
Once logged in, download a private key for your user by going to [the user's profile page](https://192.168.56.100/organizations/analytics/users/analytics), selecting `reset key` then copy the text into `.chef/analytics.pem` in this directory.

You should now be able to successfully run `knife client list` and see
`analytics-validator` as the response.



