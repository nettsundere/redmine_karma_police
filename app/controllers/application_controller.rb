class ApplicationController < ActionController::Base
  before_filter lambda { load 'redmine_karma_police/users_with_karma.rb' }
end
