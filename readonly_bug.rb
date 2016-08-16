begin
  require 'bundler/inline'
rescue LoadError => e
  $stderr.puts 'Bundler version 1.10 or later is required. Please update your Bundler'
  raise e
end

gemfile(true) do
  source 'https://rubygems.org'
  # Activate the gem you are reporting the issue against.
  gem 'activerecord', path: "~/Projects/rails"
  # gem 'arel', "6.0.3" # => Fail
  
  # Fail cases
  # gem 'activerecord', "5.0.0" # => Fail
  # gem 'activerecord', "5.0.0.rc1" # => Fail


  # Throws a "undefined method `foreign_key' for Job" error message with this combo
  # gem 'activerecord', git: 'https://github.com/rails/rails.git', ref: 'b90c85d510f0a'
  # gem 'arel', git: 'https://github.com/rails/arel.git', ref: '77ec13b46af29'
  # gem 'arel', git: 'https://github.com/rails/arel.git', ref: '66cee768bc163'

  # Pass case
  # gem 'activerecord', "4.2.6" # => Pass
  gem 'mysql2'
end

require 'active_record'
require 'minitest/autorun'
require 'logger'

# Ensure backward compatibility with Minitest 4
Minitest::Test = MiniTest::Unit::TestCase unless defined?(Minitest::Test)

# This connection will do for database-independent bug reports.
ActiveRecord::Base.establish_connection(adapter: 'mysql2', database: ':memory:')
ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table :campaigns, force: true do |t|
    t.string  :name
  end

  create_table :appeals, force: true do |t|
    t.string :name
    t.integer :campaign_id
  end
end

class Campaign < ActiveRecord::Base
  has_many :appeals
end

class Appeal < ActiveRecord::Base
  belongs_to :campaign
end

class BugTest < Minitest::Test
  def test_readonly_behavior
    campaign = Campaign.create(name: "First")
    Appeal.create(campaign: campaign, name: "First")
    Appeal.create(campaign: campaign, name: "Second")
    Appeal.create(campaign: campaign, name: "Third")

    assert_equal false, Appeal.where(id: 1).includes(:campaign).order('campaigns.name').first.campaign.readonly?
  end
end
