require 'bundler'
Bundler.require

DB = {:conn => ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'db/development.db')}
DB[:conn]
require_all 'lib'
