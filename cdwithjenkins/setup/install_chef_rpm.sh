#rpm -Uvh --oldpackage --replacepkgs "/mnt/share/chef/chef-11.16.4-1.el6.x86_64.rpm"

major=`cat /etc/redhat-release | cut -d" " -f3 | cut -d "." -f1`
rpm -Uvh --oldpackage --replacepkgs "/mnt/share/chef/chef-12.2.1-1.el$major.x86_64.rpm"

