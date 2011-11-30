# Extension for User model
# for karma police plugin.
# Do not require this source file, just load
# /lib/redmine_karma_police/users_with_karma.rb file when you need karma-related User stuff.
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

      safe_attributes :karma_editor, :karma_viewer, 
        :if => lambda {|user, current_user| current_user.admin?}
      
      has_many :karma_votes
      before_destroy lambda {|me| KarmaVote.take_back_all_from me}
      
      named_scope :good, k_opts.call(">=", 0)
      named_scope :bad, k_opts.call("<", 0)
            
      # Add +1 to another user's karma value.
      def vote_for(another_user)
        vote_with_change(another_user, 1)
      end
      
      # Substract 1 from another user's karma value.
      def vote_against(another_user)
        vote_with_change(another_user, -1)
      end
      
      private 
        def vote_with_change(another_user, change)
          begin
            raise if not karma_editor
            if change_karma_for(another_user, change) 
              KarmaVote.change(self, another_user, change)
              true
            else
              false
            end
          rescue
            errors.add_to_base I18n.t(:vote_impossible)
            false
          end
        end
      
        # Changes karma total value in User model.
        def change_karma_for(another_user, change_value)
          if another_user == self
            errors.add_to_base I18n.t(:vote_for_self)
            false
          else
            another_user.update_attribute(:karma, another_user.karma + change_value)
            true
          end
        end
    end
  end
end
