== Summit

Summit is a framework for managing servers with multiple Ruby on Rails sites.

Summit was built on "Frame":https://github.com/ncimino/frame ("Gem":https://rubygems.org/gems/frame)

Here is an example of "Summit":http://summit.econtriver.com/pages/6

== Getting Started

For Summit to create and manipulate the correct directories it needs something similar to these in the /etc/sudoers file:

```cmd
visudo
```

```cmd
nobody ALL=(root) NOPASSWD:/bin/unlink
nobody ALL=(root) NOPASSWD:/bin/ln
nobody ALL=(root) NOPASSWD:/bin/mkdir
nobody ALL=(root) NOPASSWD:/bin/ls
nobody ALL=(root) NOPASSWD:/bin/chmod
nobody ALL=(root) NOPASSWD:/usr/bin/git
nobody ALL=(root) NOPASSWD:/bin/touch
```

This is not secure!

You should limit the directories that the rails user can chmod, ls, ln, and mkdir to! See this "link":http://www.sudo.ws/pipermail/sudo-users/2010-February/004312.html for more details.

== Install

Use the Summit repo just like any other rails project.

After you pull it you'll want to modify the summit configuration file:

```ruby
#config/initializers/summit.rb
Summit::Application.configure do
  # Summit configuration
  # git_deploy_loc is the location of the git server and user used for deployment
  config.git_deploy_loc = "git@econtriver.com"
  # gitolite_tmp is where the gitolite repo is checked out to for adding users
  config.gitolite_tmp = Pathname.new("/tmp").join("gitolite-admin")
  # gitolite_user is the default user that will be added to the repo for deployment
  config.gitolite_user = '@nik'
  # valid_deploy_path is used to validate deploy paths, set to .* to remove the requirement
  config.valid_deploy_path = /\/srv\/www\/.*/i
end
```

After that, the normal bundle and migration steps.

