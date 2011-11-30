require 'redmine'
require_dependency 'redmine_karma_police/hooks/edit_karma_settings'

Redmine::Plugin.register :redmine_karma_police do
  name "Redmine Karma Police plugin"
  author "Vladimir `nettsundere` Kiselev"
  description "This is a karma-enabled plugin for Redmine. Now every user has a karma!"
  version "1.0.0"
  requires_redmine :version_or_higher => '1.2.2'
  
  url 'https://github.com/nettsundere/redmine_karma_police'
  author_url 'http://rue-m.ru'
  
  menu :top_menu, :redmine_karma_police, { :controller => "karma", :action => "index" }, 
    :caption => :karma,  
    :after => :projects, 
    :param => :project_id,
    :if => (Proc.new do  
      cur = User.current
      cur.logged? && (cur.karma_editor || cur.karma_viewer)
    end)
end

