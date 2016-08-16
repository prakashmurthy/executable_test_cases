begin
  require "bundler/inline"
rescue LoadError => e
  $stderr.puts "Bundler version 1.10 or later is required. Please update your Bundler"
  raise e
end

gemfile(true) do
  source "https://rubygems.org"
  # Activate the gem you are reporting the issue against.
  gem "activerecord", "5.0.0"
  gem "sqlite3"
end

require "active_record"
require "minitest/autorun"
require "logger"

# Ensure backward compatibility with Minitest 4
Minitest::Test = MiniTest::Unit::TestCase unless defined?(Minitest::Test)

# This connection will do for database-independent bug reports.
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table :teams, force: true do |t|
    t.string :name
  end

  create_table :deals, force: true do |t|
    t.string :name
    t.integer :team_id
  end

  create_table :events, force: true do |t|
    t.string :name
    t.integer :deal_id
  end

  create_table :users, force: true do |t|
    t.string :first_name
    t.string :last_name
  end

  create_table :events_users, force: true do |t|
    t.integer :event_id
    t.integer :user_id
    t.integer :status, default: 0
  end

  create_table :deals_users, force: true do |t|
    t.integer :deal_id
    t.integer :user_id
    t.integer :status, default: 0
  end

  create_table :team_users, force: true do |t|
    t.integer :team_id
    t.integer :user_id
    t.integer :status, default: 0
  end
end

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end

class Event < ApplicationRecord
  belongs_to :deal
  has_many :events_users
  has_many :users, through: :events_users
end

class Deal < ApplicationRecord
  belongs_to :team
  has_many :deals_users
  has_many :users, through: :deals_users
  has_many :events
end

class Team < ApplicationRecord
  has_many :deals
  has_many :team_users
  has_many :users, through: :team_users
end

class User < ApplicationRecord
  has_one :team, through: :team_user
  has_one :team_user
  has_and_belongs_to_many :deals
  has_and_belongs_to_many :events
end

class EventsUser < ApplicationRecord
  belongs_to :event
  belongs_to :user
  validates_uniqueness_of :event_id, scope: :user_id
  enum status: [:pending, :accepted, :maybe, :rejected]
end

class DealsUser < ApplicationRecord
  belongs_to :user
  belongs_to :deal
  validates_uniqueness_of :deal_id, scope: :user_id
end

class TeamUser < ApplicationRecord
  belongs_to :user
  belongs_to :team
  validates_uniqueness_of :team_id, scope: :user_id
  validates_uniqueness_of :user_id
end

User.create(first_name: "Almaz", last_name: "Ayana")
User.create(first_name: "Vivian", last_name: "Cheruiyot")

Team.create(name: "10000m")
Team.create(name: "100m")

Deal.create(name: "Half Off", team_id: 1)
Deal.create(name: "BOGO", team_id: 2)

Event.create(name: "Christmas", deal_id: 1)
Event.create(name: "Halloween", deal_id: 1)

EventsUser.create(user_id: 1, event_id: 1)
EventsUser.create(user_id: 2, event_id: 1)

TeamUser.create(user_id: 1, team_id: 1)
TeamUser.create(user_id: 2, team_id: 2)

DealsUser.create(user_id: 1, deal_id: 1)
DealsUser.create(user_id: 2, deal_id: 2)

class BugTest < Minitest::Test
  def test_join_table_update
    eu = EventsUser.first
    eu.status = "maybe"
    eu.save
    assert_equal "maybe", EventsUser.first.status
    eu.destroy
    assert_equal true, eu.destroyed?
  end
end
