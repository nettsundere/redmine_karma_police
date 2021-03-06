class CreateKarmaVotes < ActiveRecord::Migration
  def self.up
    create_table :karma_votes, :force => true do |t|
      t.references :affected
      t.references :user
      t.column :value, :integer, :default => 0, :null => false
      t.index :affected_id
      t.index :user_id
    end 
  end
  
  def self.down
    drop_table :karma_votes
  end
end
