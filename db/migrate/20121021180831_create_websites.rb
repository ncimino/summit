class CreateWebsites < ActiveRecord::Migration
  def change
    create_table :websites do |t|
      t.string :name
      t.string :domain
      t.string :deploy_path
      t.string :post_receive_path
      t.boolean :git_enabled
      t.string :nginx_path
      t.boolean :nginx_enabled

      t.timestamps
    end
  end
end
