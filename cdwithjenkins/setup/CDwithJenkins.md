#CD with Jenkins

## Assuming you have all the pre-requisites met ( ie testkitchen can startup a Centos6-6 instance )

On your workstation, ( all commands should be carried out on your workstation )

# Linx
```
 mkdir ~/Source
 cd ~/Source
```
#Windows 
```
 mkdir c:\user\<username>\Source
 cd c:\user\<username>\Source
```

Clone the dotscale workshop

```
 git clone https://github.com/chef/dotscaleworkshop
```

Now need to edit attributes and add your github and chef credentials.

```

 cd chef-cd-workshop

```

Use your favourite editor to edit the file, sublimetext, notepadd++ etc. 

```

 ./attributes/default.rb

```

Replace obvious ( ALL-CAPITAL-WORDS )parts of the following lines

```

default['jenkins']['git']['username'] = 'ENTER_GIT_USERNAME'
default['jenkins']['git']['oauth_token'] = 'ENTER_GIT_OAUTH_TOKEN'


default['jenkins']['chef']['node_name'] = 'ENTER_CHEF_USERNAME'
default['jenkins']['chef']['org_name'] = 'ENTER_CHEF_ORGNAME'


default['jenkins']['chef']['user_pem_key'] = %q(
ENTER_CHEF_USER_PEM
)


```
# Security Alert!

Note:   If you pur your private key, here, please ensure to NOT! save this repo to github as everyone/anyone will be able to download your private key.   This is for a classroom exercise only normally this key would be secured by an encrypted databag or some other vault solution.

# how to obtain your Git username and oAuth Token

Sign up to github and remember your username

Create an API token, follow instructions here:-

https://help.github.com/articles/creating-an-access-token-for-command-line-use


# how to obtain your chef username and org_name

Use your chef server from this mornings workshop.  You already have a private key...  simply use username `analytics`, and key `analytics.pem` ( you will need edit the file and copy the key into the atributes file - be careful with start and stop text ). Oh, you will need the organistation name too  `analytics`.  Finally set the node_name to `cdwithjenkins`

https://gist.github.com/thommay

# alternatives...
 Login to the manage interface on your chef server with your username/password

 Login to hosted chef with your username/password ( https://manage.chef.io )

 edit your knife.rb if you have one, your username should be there

 run the following to find where your knife.rb that you currently using lives 
 ( assuming you are in the right directory in the first place )

```
 knife status -VV 
```

# How to obtain your chef user private key ( ".pem" file )

Login to your chef server, and edit `analytics.pem` 

Alternative - The location should be in your knife.rb as per above. Copy this file into the location above named "ENTER_CHEF_USER_PEM"


# Looking good, now time to run testkitchen and see if we will be rewarded for our efforts.

At this point, a lot of things will be downloaded, by everyone in the room,  so be patient.

Whilst it is downloading have a look at the cookbooks...do you understand what it is doing?

```
kitchen converge
```

# Fix networking?, so we can easily connect to it on our local workstation.  In 
In virtualbox, select, Preferences ( not of the virtual machine,but the "master" preferences for Virtualbox ), Network, Host-only Networks, and ensure one of the adapters has the network 192.168.56.1 ( this is the default install, so it should be good, but always good to check ).

# This part is optional, for the workshop try to avoid destroying your machine as this will involve more bandwidth..

Ok, downloading the chef client is going to get really, really tedious, so let's fix that in testkitchen as follows:-

# Linux
```
 wget https://opscode-omnibus-packages.s3.amazonaws.com/el/6/x86_64/chef-12.3.0-1.el6.x86_64.rpm
```

# Windows
```
 ******** Needs more work ********
```

Edit the .kitchen.yml

```
 vi .kitchen.yml
```
  Change from this:-
```
provisioner:
  name: chef_zero
```

To this:-

```
provisioner:
  name: chef_zero  # Download and install this exact version of chef-client
  require_chef_omnibus: 12.3.0-1
  # Use the local chef-client rpm specified in install_chef_rpm.sh:
  chef_omnibus_url: file:///mnt/share/install_chef_rpm.sh  platforms:
```

But wait we need a source directory on our workstation to allow the vm to upload the file.  Well vagrant has a solution for that, called shared folders, which allows shared folders on the workstation to be mounted inside the vm.

this will be a different filename for windows, but for Centos, it is as follows

```
 mkdir /Users/<username>/chef-kits
 cp chef-12.3.0-1.el6.x86_64.rpm /Users/<username>/chef-kits/
```
obviously replace <username> with your username or select your own custom location.

Ok, but now we need to mount that inside the vm.  Again edit the .kitchen.yml file and add the following:-

```
 platforms:
  - name: centos-6.6
    driver:
      network:
        - ["private_network", {ip: "192.168.56.90"}]
        Mount local /Users/apop/chef-kits folder as /mnt/share on the VM
      synced_folders:
      - ["/Users/apop/chef-kits", "/mnt/share", "disabled: false"]
```

Now, each time we run testkiten, the chef-client will be loaded from the /mnt/share location on the vm.  No need to scp or ftp the file onto the vm.  Result!


Ok, now let's play with our Jenkins jobs....

Ensure you have a github account.  Now let's sync this account.

First login to your github account, then go to this location

```
 https://github.com/alexmanly/sample-cookbook.git
```

To fork the repo, just click the "fork" button on the top right hand side of the github window.


Ok, now we should be ready to reconverge our Jenkins server  - maybe we should


Login to jenkins with username `admin` and password `CDWorkshop` (CDW - CAPITALS)


Validate the chef Identity managment is installed...


Jenkins

Ok, now we are ready to go,  need to `rake converge`,but first a bug.....in the code, that could not be fixed before the workshop, it is possibly related to https://github.com/opscode-cookbooks/jenkins/issues/282, but time is short, so workaround time....
 
Need to take security off Jenkins before we converge....

```
 cd ./cdwithjenkins/setup
 kithen login default
 sudo vi /var/lib/jenkins/config.xml 
```

change the following line from `true` to `false`
```
 <useSecurity>false</useSecurity>
```

then run this command:-
```
 sudo service jenkins restart
```

Now cd ../  ( ie be in the cdwithjenkins directory )

Now run `rake converge`

All your changes should be propgated to the server.  Now let's login and see what has happened....

In the jenkins interface, let's go have a look...

http://192.168.56.90:8080/job/sample-cookbook-verify/configure

Jenkins, sample-cookbook-verify, configuration

Let's look for any errors, before we run anything...

Looks like `credentials`, has a problem.  Hmmmm, the converge seems not to be "converging", but let's move on....

Also, `Admin list`, a user called alexmanly has sneaked in to our admin list.  Where did that come from, who should it be and how do we fix it?

Finally, have a look at Jenkins, credentials, global credentials

Here we can see where our original converge was successful, but subsequent merge has not been.   Can you see why?

Or can we just fix it manually to see if any of this works?

Back to the credentials, seems we have a problem with git 1.7.1 not supporting the --local command.   Some workarounds and discussion here:-

http://stackoverflow.com/questions/21820715/how-to-install-latest-version-of-git-on-centos-6-x

So, let's just fix that manually to see if it all works.

```
 sudo wget -O /etc/yum.repos.d/PUIAS_6_computational.repo https://gitlab.com/gitlab-org/gitlab-recipes/raw/master/install/centos/PUIAS_6_computational.repo
 sudo wget -O /etc/pki/rpm-gpg/RPM-GPG-KEY-puias http://springdale.math.ias.edu/data/puias/6/x86_64/os/RPM-GPG-KEY-puias
 sudo rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-puias
 sudo yum --enablerepo=PUIAS_6_computational install git
```

Now check back with the gui.  Can we now run our verify job?



Configuration

To verify the plugin is installed properly, go to the Adminstration panel, then in the "Configure System" page you will find the "Chef Identity Management" section:

Further reference:-
https://wiki.jenkins-ci.org/display/JENKINS/chef-identity+plugin

