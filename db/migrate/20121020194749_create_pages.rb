class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.string :name
      t.string :title
      t.string :location
      t.text :content
      t.string :url
      t.integer :ordinal

      t.timestamps
    end
  end
end
