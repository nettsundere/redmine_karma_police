class KarmaController < ApplicationController
  unloadable
  helper KarmaHelper
  
  view_actions = [:index]
  vote_actions = [:vote]

  before_filter :check_logged
  before_filter :check_can_view, :only => view_actions
  before_filter :check_can_change, :only => vote_actions

  def index
    @good = User.good
    @bad = User.bad
  end
  
  def vote
    case params[:direction]
      when "for"
        vote_for
      when "against"
        vote_against
      else
        flash[:error] = I18n.t(:bad_type_of_vote)
    end
  
    redirect_to_index
  end
  
  private 
    
    def vote_for 
      another_user = User.find_by_id(params[:id])
      if User.current.vote_for(another_user)
        flash[:notice] = "#{another_user.name} " + I18n.t(:karma_increased)
      else
        flash[:error] = User.current.errors.on_base
      end
    end
    
    def vote_against
      another_user = User.find_by_id(params[:id])
      if User.current.vote_against(another_user)
        flash[:notice] = "#{another_user.name} " + I18n.t(:karma_decreased)
      else
        flash[:error] = User.current.errors.on_base
      end
    end
      
    # Redirect to index action of this.
    def redirect_to_index
      redirect_to :action => :index
    end
  
    # Can view karma?
    def check_can_view
      if not User.current.karma_viewer
        if User.current.karma_editor
          flash.now[:message] = I18n.t(:cannot_view_karma)
        else
          redirect_to root_path
        end
      end 
    end
    
    # Can change karma?
    def check_can_change
      if not User.current.karma_editor
        flash[:error] = I18n.t(:cannot_change_karma)
        redirect_to_index
      end 
    end
    
    def check_logged
      if not User.current.logged?
        redirect_to :controller => :login, :back_url => request.url
      end
    end
end
