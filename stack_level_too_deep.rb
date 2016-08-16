##############################################################################
# Script for https://github.com/rails/rails/issues/26122
##############################################################################
begin
  require "bundler/inline"
rescue LoadError => e
  $stderr.puts "Bundler version 1.10 or later is required. Please update your Bundler"
  raise e
end

gemfile(true) do
  source "https://rubygems.org"
  # gem "rails", '5.0.0' # fails
  # gem "rails", '4.2.7.1' # works
  gem "rails", github: 'rails/rails', branch: '4-2-stable' # works
  gem "sqlite3"
end

require "active_record"
require "minitest/autorun"
require "logger"

# This connection will do for database-independent bug reports.
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table :stats, force: true do |t|
    t.integer :count, default: 0
  end
end

class Stat < ActiveRecord::Base
end

class BugTest < Minitest::Test
  def test_association_stuff
    stat = Stat.new

    11_847.times { stat.count += 1 }

    assert stat.save
  end
end
