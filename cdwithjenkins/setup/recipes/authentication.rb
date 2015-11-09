# authentication.rb
require 'net/ssh'
key = OpenSSL::PKey::RSA.new(4096)
private_key = key.to_pem
public_key  = "#{key.ssh_type} #{[key.to_blob].pack('m0')}"

# Create the Jenkins user with the public key
jenkins_user 'chef' do
  public_keys [public_key]
end

# Set the private key on the Jenkins executor
#ruby_block 'set private key' do
#  block { node.run_state[:jenkins_private_key] = private_key }
#end
node.run_state[:jenkins_private_key] = private_key
