load 'users_with_karma.rb'

class KarmaController < ApplicationController
  unloadable

  before_filter :authorize

  def index
    @good = User.good
    @bad = User.bad
  end
  
  def vote_for
    another_user = User.find(params[:id])
    if current_user.vote_for(another_user)
      flash[:notice] = '#{another_user.name}' + I18n.t(:karma_increased)
      redirect_to :action => 'index'
    end
  end
  
  def vote_against
    another_user = User.find(params[:id])
    if current_user.vote_against(another_user)
      flash[:notice] = '#{another_user.name}' + I18n.t(:karma_decreased)
      redirect_to :action => 'index'
    end
  end
end
