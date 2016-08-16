begin
  require 'bundler/inline'
rescue LoadError => e
  $stderr.puts 'Bundler version 1.10 or later is required. Please update your Bundler'
  raise e
end

gemfile(true) do
  source 'https://rubygems.org'
  # Activate the gem you are reporting the issue against.
  # gem 'activerecord', "5.0.0" 
  # gem 'activerecord', "4.2.6"
  gem 'activerecord', path: '~/Projects/rails'
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
  create_table "groups", force: :cascade do |t|
    t.string "type"
    t.string "name"
  end

  create_table "ducks", force: :cascade do |t|
    t.string "name"
  end

  create_table "groups_users", id: false, force: :cascade do |t|
    t.integer "group_id", null: false
    t.integer "user_id",  null: false
  end

  create_table "users", force: :cascade do |t|
    t.string  "name"
    t.string  "email"
    t.integer "duck_id"
  end
end

class Group < ActiveRecord::Base
  has_and_belongs_to_many :users, join_table: 'groups_users'
end

class User < ActiveRecord::Base
  has_and_belongs_to_many :groups, join_table: 'groups_users'
  belongs_to :duck, required: false
end

class Duck < ActiveRecord::Base
  has_one :user
end

class BugTest1 < Minitest::Test
  def test_create_user_with_new_duck
    Group.create!(name: 'admin') if ! Group.exists?(name: 'admin')
    Group.create!(name: 'user') if ! Group.exists?(name: 'user')

    # Create user with new duck
    user = User.create! do |u|
      u.duck = Duck.new(name: 'quack')
      u.name = 'user 1'
      u.email = 'email@example.com'
      u.groups << Group.where(name: 'admin').first
    end
    assert_equal 1, User.count
    assert_equal 1, User.first.groups.count # Should be 1
    assert_equal 1, Duck.count

    # groups_users table has 2 rows, both of whiech are identical to [1,1]
    assert_equal 2, ActiveRecord::Base.connection.exec_query("select count(*) from groups_users").rows.first[0];
    assert_equal [[1,1],[1,1]], ActiveRecord::Base.connection.exec_query("select * from groups_users").rows

    # Delete users, ducks, group_users tables to bring it to the initial state
    ActiveRecord::Base.connection.execute("delete from users")
    ActiveRecord::Base.connection.execute("delete from ducks")
    ActiveRecord::Base.connection.execute("delete from groups_users")

    # Create user without a new duck
    user = User.create! do |u|
      u.name = 'user 2'
      u.email = 'email2@example.com'
      u.groups << Group.where(name: 'admin').first
    end

    assert_equal 1, User.count
    assert_equal 1, User.first.groups.count
    assert_equal 0, Duck.count

    # groups_users table has 1 row
    assert_equal 1, ActiveRecord::Base.connection.exec_query("select count(*) from groups_users").rows.first[0];
    assert_equal [[1,2]], ActiveRecord::Base.connection.exec_query("select * from groups_users").rows
  end
end
