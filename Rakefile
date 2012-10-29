#!/usr/bin/env rake

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Summit::Application.load_tasks

files = ['config/database.yml','config/initializers/secret_token.rb']

domain = "#{Rails.application.class.parent_name.downcase}.econtriver.com"
user = "root"  # The server's user for deploys
deploy_to = "/srv/www/#{domain}"

task :setup_server_db do
  system("ssh #{user}@#{domain} 'cd #{File.join(deploy_to,'current')};rake db:setup RAILS_ENV=production'")
end

task :put_secret do
  files.each do |f|
    system("scp #{f} #{user}@#{domain}:#{File.join(deploy_to,'private',f)}")
  end
end

task :get_secret do
  files.each do |f|
    system("scp #{user}@#{domain}:#{File.join(deploy_to,'private',f)} #{f}")
  end
end

task :backup do
  filename = "#{Rails.application.class.parent_name.downcase}.db_backup.#{Time.now.to_f}.sql.bz2"
  filepath = File.join(deploy_to,'current',filename)
  config = YAML.load_file(File.join(deploy_to,'private', 'config', 'database.yml'))
  system("mysqldump -u #{config['production']['username']} -p'#{config['production']['password']}' #{config['production']['database']} | bzip2 -c > #{filepath}\n")
end
