begin
  require 'bundler/inline'
rescue LoadError => e
  $stderr.puts 'Bundler version 1.10 or later is required. Please update your Bundler'
  raise e
end

gemfile(true) do
  source 'https://rubygems.org'
  # Activate the gem you are reporting the issue against.
  # gem 'activerecord', '4.2.6'
  gem 'activerecord', path: '~/Projects/rails'
  # gem 'arel', git: 'https://github.com/rails/arel.git', ref: '77ec13b46af292'
  gem 'sqlite3'
  # gem 'builder'
  # gem 'json'
  # gem 'method_source'
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
  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_roles", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["role_id"], name: "index_user_roles_on_role_id"
    t.index ["user_id"], name: "index_user_roles_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end
end

class Role < ActiveRecord::Base
  validates_presence_of :name
end

class User < ActiveRecord::Base
  has_many :user_roles
  has_many :roles, through: :user_roles, validate: false
end

class UserRole < ActiveRecord::Base
  belongs_to :user
  belongs_to :role
end

class BugTest < Minitest::Test
  def test_association_stuff
    Role.new(name: nil).save(validate: false) # deliberately creating an invalid nameless role

    u = User.create!(role_ids: ["1"]) # OK
    u.update!(role_ids: nil) # OK
    u.update!(role_ids: ["1"]) # FAILS
  end
end

