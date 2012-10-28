class AddGitRepoPathToWebsites < ActiveRecord::Migration
  def change
    add_column :websites, :git_repo_path, :string
  end
end
