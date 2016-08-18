##############################################################################
# Script for https://github.com/rails/rails/issues/26210
##############################################################################
begin
  require "bundler/inline"
rescue LoadError => e
  $stderr.puts "Bundler version 1.10 or later is required. Please update your Bundler"
  raise e
end

gemfile(true) do
  source "https://rubygems.org"
  gem "rails", '5.0.0' # fails
  # gem "rails", '4.2.5.1' # works
  gem "sqlite3"
end

require "active_record"
require "minitest/autorun"
require "logger"

# This connection will do for database-independent bug reports.
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table :accounts, force: :cascade do |t|
  end
end

class Account < ActiveRecord::Base
end

class BugTest < Minitest::Test
  def test_create_account
    account = Account.create!
    Account.create!
    Account.create!

    assert_equal account, Account.find_by(id: account)
  end
end
