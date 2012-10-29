Summit::Application.configure do
  # Summit configuration
  # git_deploy_loc is the location of the git server and user used for deployment
  config.git_deploy_loc = "g@econtriver.com"
  # gitolite_tmp is where the gitolite repo is checked out to for adding users
  config.gitolite_tmp = Rails.root.join('tmp', 'gitolite-admin')
  # gitolite_user is the default user that will be added to the repo for deployment
  config.gitolite_user = '@nik'
  # valid_deploy_path is used to validate deploy paths, set to ,* to remove requirement
  config.valid_deploy_path = /\/srv\/www\/.*/i
end
