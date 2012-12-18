class CreateStories < ActiveRecord::Migration
  def up
    create_table :verblog_stories do |t|
      t.string :title, :null => false
      
      t.text :intro
      t.text :body
      
      t.string :url_string, :null => false, :default => ""
      
      t.datetime :timestamp, :null => false
      t.integer :status, :default => 0, :null => false
      t.string :story_asset_scheme
      
      t.timestamps
    end
  end

  def down
    drop_table :verblog_stories
  end
end
