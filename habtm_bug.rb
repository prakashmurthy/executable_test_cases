begin
  require 'bundler/inline'
rescue LoadError => e
  $stderr.puts 'Bundler version 1.10 or later is required. Please update your Bundler'
  raise e
end

gemfile(true) do
  source 'https://rubygems.org'
  # Activate the gem you are reporting the issue against.
  # gem 'activerecord', path: "~/Projects/rails"
  
  # Fail cases
  # gem 'activerecord', "5.0.0" # => Fail
  # gem 'activerecord', "5.0.0.rc1" # => Fail


  # Throws a "undefined method `foreign_key' for Job" error message with this combo
  gem 'activerecord', git: 'https://github.com/rails/rails.git', ref: 'b90c85d510f0a'
  gem 'arel', git: 'https://github.com/rails/arel.git', ref: '66cee768bc163'

  # Pass case
  # gem 'activerecord', "4.2.6" # => Pass
  gem 'sqlite3'
end

require 'active_record'
require 'minitest/autorun'
require 'logger'

# Ensure backward compatibility with Minitest 4
Minitest::Test = MiniTest::Unit::TestCase unless defined?(Minitest::Test)

# This connection will do for database-independent bug reports.
ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table :users, force: true do |t|
    t.string  :name
  end

  create_table :jobs, force: true do |t|
    t.string :name
  end

  create_table :jobs_pool, id: false do |t|
    t.references :job, null: false, index: true
    t.references :user, null: false, index: true
  end
end

class Job < ActiveRecord::Base
end

class User < ActiveRecord::Base
  has_and_belongs_to_many :jobs_pool,
   class_name: Job,
   join_table: 'jobs_pool'
end

class BugTest < Minitest::Test
  def test_jobs_pool_clear
    User.create(name: 1)
    Job.create(name: 1)
    User.first.jobs_pool = Job.all
    User.first.jobs_pool.clear
  end
end
