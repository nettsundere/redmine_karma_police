module KarmaHelper
  def karma_block_for(user)
    is_self = User.current == user
    can_vote = User.current.karma_editor
    can_view = User.current.karma_viewer
    
    vote_against_opts = { :action => :vote, :direction => :against, :id => user }
    vote_for_opts = { :action => :vote, :direction => :for, :id => user }
    
    output = ''
    
    if can_view
      output << content_tag(:span, user.karma)
    else
      output << content_tag(:span, "?")
    end
    
    if !is_self && can_vote
      output = (link_to image_tag("against.png", :alt => t(:vote_against), :plugin => :redmine_karma_police), 
              vote_against_opts, 
              :method => :put) + output
              
      output << (link_to image_tag("for.png", :alt => t(:vote_for), :plugin => :redmine_karma_police), 
              vote_for_opts,
              :method => :put)
    end
    
    output
  end
end
