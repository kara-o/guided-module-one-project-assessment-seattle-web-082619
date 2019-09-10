require_relative 'config/environment'
require 'sinatra/activerecord/rake'

desc 'starts a console'
task :console do
  ActiveRecord::Base.logger = Logger.new(STDOUT)
  Pry.start
end

# desc "Seed the database with some normal data"
# task :seed do
#   puts "seeding database..."
#   DB[:conn].execute("DROP TABLE IF EXISTS notes")
#   DB[:conn].execute("CREATE TABLE notes (id integer PRIMARY KEY, text string, is_complete string)")
#   DB[:conn].execute("INSERT INTO notes(text, is_complete) VALUES('buy milk', 'incomplete'), ('feed cat', 'incomplete')")
#   puts "Created #{Note.all.length} notes"
# end
