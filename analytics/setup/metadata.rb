name 'analytics-workshop'
description 'Configure Chef Server and Analytics'
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '1.0.0'

depends "chef-server-ingredient"
depends "chef-server-cluster"
