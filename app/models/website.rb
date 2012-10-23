class Website < ActiveRecord::Base
  attr_accessible :deploy_path, :domain, :git_enabled, :name, :nginx_enabled, :nginx_path, :post_receive_path
end
