class Website < ActiveRecord::Base
  before_save :create_deploy_dir, :add_user_to_repository
  validates_presence_of :deploy_path, :domain, :name, :nginx_path, :post_receive_path
  validates_uniqueness_of :deploy_path, :domain, :name, :nginx_path, :post_receive_path
  validates_format_of :deploy_path, :with => Summit::Application.config.valid_deploy_path, :message => "should match #{Summit::Application.config.valid_deploy_path.source.to_s.gsub(/\\|\./,'')}"
  attr_accessible :deploy_path, :domain, :git_enabled, :name, :nginx_enabled, :nginx_path, :post_receive_path

  private

  def add_user_to_repository
    lexec "git config user.name summit"
    lexec "git config user.email summit@econtriver.com"
    lexec "rm -rf #{Summit::Application.config.gitolite_tmp}"
    lexec "git clone #{Summit::Application.config.git_deploy_loc}:gitolite-admin #{Summit::Application.config.gitolite_tmp} 2>&1"
    add_user_to_conf
    lexec "git --git-dir=#{Summit::Application.config.gitolite_tmp.join('.git')} --work-tree=#{Summit::Application.config.gitolite_tmp} add ."
    lexec "git --git-dir=#{Summit::Application.config.gitolite_tmp.join('.git')} --work-tree=#{Summit::Application.config.gitolite_tmp} " +
          "commit -m 'added user #{Summit::Application.config.gitolite_user} to #{name}'"
    lexec "git push origin master"
  end

  def create_deploy_dir
    create_dir deploy_path
  end

  def add_user_to_conf
    begin
      file_name     = Summit::Application.config.gitolite_tmp.join('conf', 'gitolite.conf')
      file_content  = File.read(file_name)
      repo_line     = "\nrepo #{name}\n"
      line_to_add   = "    RW+     =   #{Summit::Application.config.gitolite_user}"
      user_in_repo  = /(#{repo_line})(.*=.*\n)*(.*=   #{Summit::Application.config.gitolite_user})/
      add           = repo_line + line_to_add + "\n"

      # unless the user already exists for this repo
      File.open(file_name,'w') { |f| f.write(file_content.gsub(/#{repo_line}/,add))} unless user_in_repo =~ file_content
      File.open(file_name,'a') { |f| f.write(add) } unless file_content.include? repo_line
      raise "failed to write to #{file_name}" unless file_content.include? repo_line

    rescue Exception => e
      errors[:base] << "Could not #{caller[1][/`.*'/][1..-2].gsub(/_/,' ')}, due to<br /> #{e.message}".html_safe
      false
    end
  end

  def create_dir(path)
    unless Dir.exists?(path)
      begin
        Dir.mkdir(path)
      rescue
        errors.add(:deploy_path, "could not be created: #{path}")
        false
      end
    end
  end

  def lexec(cmd)
    begin
      output = `#{cmd}`
      raise output unless /exit 0/ =~ $?.to_s
    rescue Exception => e
      errors[:base] << "Could not #{caller[1][/`.*'/][1..-2].gsub(/_/,' ')}, due to<br /> #{e.message}".html_safe
      false
    end
  end

end
