class Website < ActiveRecord::Base
  before_save :create_deploy_dir , :create_post_receive_file, :create_nginx_file, :enable_nginx, :enable_git
  before_create :add_user_to_repository
  validates_presence_of :deploy_path, :domain, :name, :nginx_path, :post_receive_path, :enabled_nginx_path,
                        :enabled_git_path, :git_repo_path
  validates_uniqueness_of :deploy_path, :domain, :name, :nginx_path, :post_receive_path, :enabled_nginx_path,
                          :enabled_git_path, :git_repo_path
  validates_format_of :deploy_path, :with => Summit::Application.config.valid_deploy_path,
                :message => "should match #{Summit::Application.config.valid_deploy_path.source.to_s.gsub(/\\|\./,'')}"
  attr_accessible :enabled_git_path, :enabled_nginx_path, :deploy_path, :domain, :git_enabled, :name, :nginx_enabled,
                  :nginx_path, :post_receive_path, :git_repo_path

  def run_step(step)
    case step
      when 'deploy_path'
        create_deploy_dir
      when 'nginx_path'
        create_nginx_file(true)
      when 'add_user_to_repository'
        add_user_to_repository(true)
      when 'post_receive_path'
        create_post_receive_file(true)
      when 'enabled_nginx_path'
        enable_nginx
      when 'enabled_git_path'
        enable_git
      else
        errors[:base] << "The #{caller[0][/`.*'/][1..-2].gsub(/_/,' ')} '#{step} is not a recognized step.".html_safe
        return false
    end
  end

  def get_checks
    checks = Hash.new
    [:deploy_path, :nginx_path, :post_receive_path, :enabled_nginx_path, :enabled_git_path].each do |path|
      checks.merge!(path => true) if File::exists? self[path]
    end
    checks
  end

  def user_in_conf?
    begin
      file_name       = Summit::Application.config.gitolite_tmp.join('conf', 'gitolite.conf')
      if File.exists?(file_name)
        file_content  = File.read(file_name)
        repo_line     = "\nrepo #{name}\n"
        user_in_repo  = /(#{repo_line})(.*=.*\n)*(.*=   #{Summit::Application.config.gitolite_user})/
        user_in_repo =~ file_content
      else
        false
      end
    rescue Exception => e
      errors[:base] << "Could not find #{caller[0][/`.*'/][1..-2].gsub(/_/,' ').gsub(/\?/,'')}, due to <br />
        #{e.message}".html_safe
      false
    end
  end

  private

  def add_user_to_repository(force = false)

    #chmod 777 /srv/www/summit.econtriver.com/releases/20121029_003513/tmp/
    #Rails.logger.debug "Tmp Dir: #{Summit::Application.config.gitolite_tmp.join('.git')}"
    begin
      if force or !user_in_conf?
        #lexec "git config user.name summit"
        #lexec "git --git-dir=#{Summit::Application.config.gitolite_tmp} --work-tree=#{Summit::Application.config.gitolite_tmp} " +
        #      "config user.name summit"
        #lexec "git config user.email summit@econtriver.com"
        #lexec "git --git-dir=#{Summit::Application.config.gitolite_tmp} --work-tree=#{Summit::Application.config.gitolite_tmp} " +
        #      "config user.email summit@econtriver.com"
        #FileUtils.rm_rf(Summit::Application.config.gitolite_tmp)
        #lexec "rm -rf #{Summit::Application.config.gitolite_tmp}"
        #create_dir Summit::Application.config.gitolite_tmp
        #lexec "chmod 777 #{Summit::Application.config.gitolite_tmp}"
        if File.exists?(Summit::Application.config.gitolite_tmp)
          lexec "git --git-dir=#{Summit::Application.config.gitolite_tmp} --work-tree=#{Summit::Application.config.gitolite_tmp} " +
                "fetch"
          lexec "git --git-dir=#{Summit::Application.config.gitolite_tmp} --work-tree=#{Summit::Application.config.gitolite_tmp} " +
                "merge origin/master"
          #lexec "git --git-dir=#{Summit::Application.config.gitolite_tmp} --work-tree=#{Summit::Application.config.gitolite_tmp} " +
          #      "pull origin master"
        else
          lexec "git --git-dir=#{Summit::Application.config.gitolite_tmp} --work-tree=#{Summit::Application.config.gitolite_tmp} " +
                "clone #{Summit::Application.config.git_deploy_loc}:gitolite-admin.git #{Summit::Application.config.gitolite_tmp}"
        end
        lexec "git --git-dir=#{Summit::Application.config.gitolite_tmp} --work-tree=#{Summit::Application.config.gitolite_tmp} " +
                  "config user.name summit"
        lexec "git --git-dir=#{Summit::Application.config.gitolite_tmp} --work-tree=#{Summit::Application.config.gitolite_tmp} " +
                  "config user.email summit@econtriver.com"
        unless user_in_conf?
          add_user_to_conf
          lexec "git --git-dir=#{Summit::Application.config.gitolite_tmp} --work-tree=#{Summit::Application.config.gitolite_tmp} " +
                "add ."
          lexec "git --git-dir=#{Summit::Application.config.gitolite_tmp} --work-tree=#{Summit::Application.config.gitolite_tmp} " +
                "commit -m 'added user #{Summit::Application.config.gitolite_user} to #{name}'"
          lexec "git --git-dir=#{Summit::Application.config.gitolite_tmp} --work-tree=#{Summit::Application.config.gitolite_tmp} " +
                "push origin master"
        end
      end
      true
    rescue Exception => e
      errors[:base] << "Could not #{caller[0][/`.*'/][1..-2].gsub(/_/,' ')}, due to<br /> #{e.message}".html_safe
      false
    end
  end

  def create_nginx_file(force = false)
    begin
      FileUtils.rm_rf(nginx_path) if force
      unless File.exists?(nginx_path)
        create_dir File.dirname(nginx_path)
        erb = ERB.new(File.read(File.join(Rails.root, 'lib', 'templates', 'nginx'))).result(binding)
        File.open(nginx_path, 'w') { |f| f.write(erb) }
        lexec "chmod 644 #{nginx_path}"
      end
      true
    rescue Exception => e
      errors[:base] << "Could not #{caller[0][/`.*'/][1..-2].gsub(/_/,' ')}, due to:<br /> #{e.message}".html_safe
      false
    end
  end

  def enable_git
    begin
      create_dir File.dirname(enabled_git_path)
      lexec "unlink #{enabled_git_path}" if File.exists?(enabled_git_path)
      lexec "ln -s #{git_repo_path} #{enabled_git_path}" if git_enabled
      true
    rescue Exception => e
      errors[:base] << "Could not #{caller[0][/`.*'/][1..-2].gsub(/_/,' ')}, due to:<br /> #{e.message}".html_safe
      false
    end
  end

  def enable_nginx
      #chmod 777 /etc/nginx/sites-enabled/summit.econtriver.com
      #chmod 777 /etc/nginx/sites-available/summit.econtriver.com
    #chmod 777 /etc/nginx/sites-enabled/
    begin
      create_dir File.dirname(enabled_nginx_path)
      lexec "unlink #{enabled_nginx_path}" if File.exists?(enabled_nginx_path)
      lexec "ln -s #{nginx_path} #{enabled_nginx_path}" if nginx_enabled
      true
    rescue Exception => e
      errors[:base] << "Could not #{caller[0][/`.*'/][1..-2].gsub(/_/,' ')}, due to:<br /> #{e.message}".html_safe
      false
    end
  end

  def create_post_receive_file(force = false)
    #chmod 777 /home/g/repositories/summit.git
    #chmod 777 /home/g/repositories/summit.git/hooks/post-receive
    begin
      #Process.euid = 0
      #Process.uid = 0
      #uid = Etc.getpwnam("root").uid
      #Process::Sys.setuid(uid)
      FileUtils.rm_rf(post_receive_path) if force
      unless File.exists?(post_receive_path)
        create_dir File.dirname(post_receive_path)
        lexec "chmod 777 #{File.dirname(File.dirname(post_receive_path))}"
        lexec "chmod 777 #{File.dirname(post_receive_path)}"
        lexec "touch #{post_receive_path}"
        lexec "chmod 777 #{post_receive_path}"
        erb = ERB.new(File.read(File.join(Rails.root, 'lib', 'templates', 'post-receive'))).result(binding)
        File.open(post_receive_path, 'w') { |f| f.write(erb) }
      end
      true
    rescue Exception => e
      errors[:base] << "Could not #{caller[0][/`.*'/][1..-2].gsub(/_/,' ')}, due to:<br /> #{e.message}".html_safe
      false
    end
  end

  def create_deploy_dir
    begin
      create_dir deploy_path
      create_dir File.join(deploy_path, 'releases')
      create_dir File.join(deploy_path, 'shared', 'uploads')
      create_dir File.join(deploy_path, 'shared', 'logs')
      create_dir File.join(deploy_path, 'private', 'config', 'initializers')
      create_dir File.join(deploy_path, 'private', 'certs')
      true
    rescue
      errors.add(:deploy_path, "could not be created: #{path}")
      false
    end
  end

  def add_user_to_conf
    file_name     = Summit::Application.config.gitolite_tmp.join('conf', 'gitolite.conf')
    file_content  = File.read(file_name)
    repo_line     = "\nrepo #{name}\n"
    line_to_add   = "    RW+     =   #{Summit::Application.config.gitolite_user}"
    add           = repo_line + line_to_add + "\n"

    lexec "chmod 777 #{file_name}"
    # add user to repo unless the user already exists for this repo
    File.open(file_name,'w') { |f| f.write(file_content.gsub(/#{repo_line}/,add))} unless user_in_conf?
    # add user and repo unless the repo exists
    File.open(file_name,'a') { |f| f.write(add) } unless file_content.include? repo_line
    # check that repo exists
    raise "failed to write to #{file_name}" unless user_in_conf?
    true
  end

  def create_dir(path)
    unless Dir.exists?(path)
      #Dir.mkdir_p(path)
      lexec "mkdir -p #{path}"
      lexec "ls #{path}"
    end
    #raise Exception, "Directory not present after creation #{path}" unless Dir.exists?(path)
    true
  end

  def lexec(cmd)
    Rails.logger.debug cmd
    output = `sudo #{cmd} 2>&1`
    raise output unless /exit 0/ =~ $?.to_s
    output
  end

  #def lexec(command)
  #  output = `echo #{azmodan} | sudo -S '#{command}'`
  #  #end
  #  raise output unless /exit 0/ =~ $?.to_s
  #  output
  #end

end
