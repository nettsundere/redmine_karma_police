require 'rake'
require 'spec/rake/spectask'

task :default => :spec

desc "Run all examples"
Spec::Rake::SpecTask.new("spec") {|t| t.spec_files = FileList["spec/**/*.rb"] }

desc "Prepare redmine database for the test"
task :prepare do
  this_directory = File.dirname __FILE__
  prepare_db = "cd ../ \
  && rake environment RAILS_ENV=test db:drop db:create db:migrate db:migrate_plugins \
  && cd #{this_directory}"
  system prepare_db
end
