class CreateStoryAssets < ActiveRecord::Migration
  def up
    create_table :verblog_story_assets do |t|
      t.belongs_to :story, :null => false
      t.belongs_to :asset, :null => false
      t.integer :position, :null => false, :default => 99
      t.string :caption
    end
  end

  def down
    drop_table :verblog_story_assets
  end
end
