require 'redmine'

Redmine::Plugin.register :redmine_karma_police do
  name "Redmine Karma Police plugin"
  author "Vladimir `nettsundere` Kiselev"
  description "This is a karma-enabled plugin for Redmine. Now every user has a karma!"
  version "0.0.1"
  requires_redmine :version_or_higher => '1.2.2'
  
  url 'https://github.com/nettsundere/redmine_karma_police'
  author_url 'http://rue-m.ru'
  
  menu :top_menu, :redmine_karma_police, { :controller => "karma", :action => "index" }, 
    :caption => :karma,  
    :after => :projects, 
    :param => :project_id

  project_module :karma do
    permission :view_karma, :karma => :top
    permission :change_karma, :karma => [:vote_for, :vote_against]
  end
end

