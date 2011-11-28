class AddUsersKarmaSettings < ActiveRecord::Migration
  def self.up
    add_column :users, :karma_editor, :boolean, :default => 0
    add_column :users, :karma_viewer, :boolean, :default => 0
  end
  
  def self.down
    remove_column :users, :karma_editor
    remove_column :users, :karma_viewer
  end
end
