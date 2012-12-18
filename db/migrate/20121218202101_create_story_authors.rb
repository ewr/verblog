class CreateStoryAuthors < ActiveRecord::Migration
  def up
    create_table :verblog_story_authors do |t|
      t.belongs_to :story, :null => false
      t.belongs_to :user
      t.boolean :is_primary, :default => true, :null => false
    end
  end

  def down
    drop_table :verblog_story_authors
  end
end
