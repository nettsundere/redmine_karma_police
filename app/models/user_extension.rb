# Extension for User model
# for karma police plugin.
# Do not require this source file, just load
# /lib/users_with_karma.rb file when you need karma-related User stuff.
module UserExtension  
  def self.included(klass)
    super
    
    # Used to construct options for named_scope
    # based on karma comparison
    # karma #{how_to_compare} value
    # for example: karma >= 0 
    # and login != ""
    k_opts = lambda do |how_to_compare, value| 
      { 
        :conditions => ["karma #{how_to_compare} ? AND login !=?", value, ""],
        :order => "karma DESC"
      }
    end
    
    klass.class_exec(k_opts) do |k_opts|
      attr_protected :karma
      has_many :karma_votes
      before_destroy lambda {|me| KarmaVote.take_back_all_from me}
      
      named_scope :good, k_opts.call(">=", 0)
      named_scope :bad, k_opts.call("<", 0)
            
      # Add +1 to another user's karma value.
      def vote_for(another_user)
        change = 1
        if change_karma_for(another_user, change)
          KarmaVote.change(self, another_user, change)
        end
      end
      
      # Substract 1 from another user's karma value.
      def vote_against(another_user)
        change = -1 
        if change_karma_for(another_user, change) 
          KarmaVote.change(self, another_user, change)
        end
      end
      
      private 
        # Changes karma total value.
        def change_karma_for(another_user, change_value)
          if another_user == self
            errors.add_to_base I18n.t(:vote_for_self)
            false
          else
            another_user.update_attribute(:karma, another_user.karma + change_value)
          end
        end
    end
  end
end
