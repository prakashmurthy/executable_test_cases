##############################################################################
# Script for https://github.com/rails/rails/issues/26244
##############################################################################
begin
  require "bundler/inline"
rescue LoadError => e
  $stderr.puts "Bundler version 1.10 or later is required. Please update your Bundler"
  raise e
end

gemfile(true) do
  source "https://rubygems.org"
  gem 'rails', '5.0.0.1'
  gem "mysql2"
end

require "active_record"
require "minitest/autorun"
require "logger"

# This connection will do for database-independent bug reports.
ActiveRecord::Base.establish_connection(adapter: "mysql2", database: "dev_rails_db")
ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table :payments, force: :cascade do |t|
    t.datetime :date
  end
end

class Payment < ActiveRecord::Base
end

class BugTest < Minitest::Test
  def test_create_account
    payment = Payment.create!(date: '2016-08-21 00:53:19')
    # assert_equal Date, Payment.select("DATE(date) as d").first.d.class
    # assert_equal Date, Payment.select("DATE(date) as date").first.date.class
    # assert_equal Date.parse('2016-08-21'), Payment.select("DATE(date) as d").first.d
    # assert_equal Date.parse('2016-08-21'), Payment.select("DATE(date) as date").first.date
    assert_nil Payment.select("DATE(date) as date").first.date
  end
end
