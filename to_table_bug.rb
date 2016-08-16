begin
  require 'bundler/inline'
rescue LoadError => e
  $stderr.puts 'Bundler version 1.10 or later is required. Please update your Bundler'
  raise e
end

gemfile(true) do
  source 'https://rubygems.org'
  # Activate the gem you are reporting the issue against.
  gem 'activerecord', "5.0.0"
  gem 'sqlite3'
  gem 'railties'
end

require 'active_record'
require 'minitest/autorun'
require 'logger'
require 'railties/'

# Ensure backward compatibility with Minitest 4
Minitest::Test = MiniTest::Unit::TestCase unless defined?(Minitest::Test)

# This connection will do for database-independent bug reports.
ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table :users, force: true do |t|
    t.string  :name
  end

  create_table :restaurants, force: true do |t|
    t.string :name
  end
end

class AddUsersRefToRestaurants < ActiveRecord::Migration
  add_reference :restaurants, :admin, :index => true, :foreign_key => { :to_table => :users }
end

class BugTest < Minitest::Test
  def test_migrate_rollback

    
  end
end
