class AddEnabledNginxPathToWebsites < ActiveRecord::Migration
  def change
    add_column :websites, :enabled_nginx_path, :string
  end
end
