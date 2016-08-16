##############################################################################
# Script for https://github.com/rails/rails/issues/26108
##############################################################################
begin
  require "bundler/inline"
rescue LoadError => e
  $stderr.puts "Bundler version 1.10 or later is required. Please update your Bundler"
  raise e
end

gemfile(true) do
  source "https://rubygems.org"
  # gem 'rails', '5.0.0' # fails
  # gem 'rails', '4.2.7.1' # fails
  # gem "rails", '4.2.1' # works
  # gem "rails", github: "rails/rails", branch: '4-2-stable' # works
  gem "rails", github: "rails/rails", branch: '4-1-stable' # fails
  gem "sqlite3"
  gem 'pry'
end

require "active_record"
require "minitest/autorun"
require "logger"

# This connection will do for database-independent bug reports.
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table :things, force: true do |t|
   t.decimal :price, precision: 4, scale: 4
  end

end

class Thing < ActiveRecord::Base
end


class BugTest < Minitest::Test
  def test_association_stuff
    thing = Thing.create!
    thing.price = 0.0001
    assert_equal '0.0001', thing.price.to_s

    thing.price = 0.00001
    assert_equal '0.00001', thing.price.to_s
  end
end
