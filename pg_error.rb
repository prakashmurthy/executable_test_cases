begin
  require 'bundler/inline'
rescue LoadError => e
  $stderr.puts 'Bundler version 1.10 or later is required. Please update your Bundler'
  raise e
end

gemfile(true) do
  source 'https://rubygems.org'
  gem "rails", ">= 5.0.0.rc1", "< 5.1"
  gem "pg", "~> 0.18.4"
end

require "active_record"
require "minitest/autorun"
require "logger"
require "date"

# This connection will do for database-independent bug reports.
ActiveRecord::Base.establish_connection(adapter: "postgresql", database: "rails_app_care_test")
ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table :events do |t|
    t.timestamp :start_at
    t.timestamp :end_at
  end
end

class Event < ActiveRecord::Base
end

class BugTest < Minitest::Test
  def setup
    @event = Event.create!(end_at: DateTime.strptime("1464559200000","%Q"))
  end

  def test_datetime
    assert_respond_to @event.end_at, "to_f", "Could not get float from #{@event.end_at}"
  end
end
