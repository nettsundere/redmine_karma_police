require 'redmine'

Redmine::Plugin.register :redmine_karma_police do
  name 'Redmine Karma Police plugin'
  author 'Vladimir `nettsundere` Kiselev'
  description 'This is a karma-enabled plugin for Redmine. Now every user has a karma!'
  version '0.0.1'
  url 'https://github.com/nettsundere/redmine_karma_police'
  author_url 'http://rue-m.ru'
  menu :application_menu, :redmine_karma_police, { :controller => 'karma', :action => 'index' }, :caption => 'Karma'
end
