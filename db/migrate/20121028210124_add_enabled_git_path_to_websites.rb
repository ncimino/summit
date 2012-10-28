class AddEnabledGitPathToWebsites < ActiveRecord::Migration
  def change
    add_column :websites, :enabled_git_path, :string
  end
end
