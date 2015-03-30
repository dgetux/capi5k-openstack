task :xp5k do
  puts "  XP5K launched (submission and deployment)"
end


desc 'Submit jobs'
task :submit do
  $myxp.submit
  $myxp.wait_for_jobs
end

desc 'Deploy with Kadeploy'
task :deploy  do
  $myxp.deploy
end

desc 'Remove all running jobs'
task :clean do
logger.debug "Clean all Grid'5000 running jobs..."
  $myxp.clean
end

desc 'Describe the cluster'
task :describe do
  servers = find_servers
  servers_by_roles = {}
  servers.each do |server|
    role_names = role_names_for_host(server)
    role_names.each do |role|
      servers_by_roles[role] ||= [] 
      servers_by_roles[role] << server
    end
  end 
  puts "+----------------------------------------------------------------------+"
  servers_by_roles.each do |role, servers|
    print "|"+"%-30s".blue % role
    server = servers.pop
    puts "%-40s|" % server
    servers.each do |server|
      print "|"+"%-30s" % " "
      puts "%-40s|" % server
    end 
    puts "+----------------------------------------------------------------------+"
  end
end

desc 'Prepare my stuff'
task :prepare, :roles => [:controller] do
  set :user, "root"
  set :default_environment, { 
    "http_proxy"  => "http://proxy:3128",
    "https_proxy" => "http://proxy:3128",
    "OS_USERNAME" => "test",
    "OS_PASSWORD" => "abc123",
    "OS_TENANT_NAME" => "test",
    "OS_AUTH_URL" => "http://localhost:5000/v2.0/"
  }
  run "apt-get install --yes git && 
    git clone https://davidguyon@bitbucket.org/davidguyon/greenerbar.git && 
    cd greenerbar &&
    bash install-greenerbar.bash &&
    unset http_proxy https_proxy &&
    nova keypair-add test_key > ~/.ssh/test_key.pem &&
    chmod 600 ~/.ssh/test_key.pem &&
    echo 'export EC2_KEYPAIR=test_key' >> ~/.bashrc &&
    echo 'export EC2_SECURITY_GROUP=vm_jdoe_sec_group' >> ~/.bashrc"
end

desc 'Send FRIEDA on controller'
task :FRIEDA, :roles => [:controller] do
  set :user, "root"
  set :default_environment, { 
    "http_proxy"  => "http://proxy:3128",
    "https_proxy" => "http://proxy:3128"
  }
  upload "/home/dguyon/FRIEDA/", "FRIEDA", :via => :scp, :recursive => :true
  run "cd FRIEDA &&
    ./setup.py build &&
    ./setup.py install"
end

after "xp5k", "submit", "deploy"
