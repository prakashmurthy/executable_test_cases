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
  gem 'activerecord', "3.2.22.4"
  gem 'minitest'
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
  create_table "accounts", force: :cascade do |t|
    t.integer  "bank_id"
    t.integer  "person_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "accounts", ["bank_id"], name: "index_accounts_on_bank_id"
  add_index "accounts", ["person_id"], name: "index_accounts_on_person_id"

  create_table "banks", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "people", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end
end

class Person < ActiveRecord::Base
end

class Bank < ActiveRecord::Base
  has_many :accounts
  has_many :people, through: :accounts
end

class Account < ActiveRecord::Base
  belongs_to :bank
  belongs_to :person

  after_update :this_should_not_run

  def this_should_not_run
    raise "when did I ever update an account?"
  end
end

class BugTest1 < Minitest::Test
  def test_create_user_with_new_duck
    person = Person.create!(name: "William")
    assert Bank.create!(name: "Stacks of Money", person_ids: [person.id])
  end
end
