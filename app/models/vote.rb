class Vote < ActiveRecord::Base
  belongs_to :user
  has_one :affected, :class_name => User  
  
  class << self
    # Changes karma value of affected_user caused by user.
    def change(user, another_user, change_value)
      if another_user == self
        errors.add_to_base I18n.t(:vote_for_self)
        false
      else
        my_vote = Vote.find_or_initialize_by_user_id_and_affected_id(user.id, another_user.id)
        new_value = my_vote.value + change_value
        my_vote.update_attributes(:user_id => user.id, :affected_id => another_user.id, :value => new_value)
      end
    end
    
    # Take all votes from the user back.
    def take_back_all_from(user)
      options = ["user_id = ?", user.id]
      my_votes = Vote.all options
      my_votes.each do |vote|
        val = vote.value
        affected = User.find_by_id(vote.affected_id) || next
        affected.update_attribute(:karma, affected.karma - val)
      end
      Vote.delete_all options
    end
  end
end
