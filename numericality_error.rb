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
  create_table :products do |t|
    t.string :name
    t.text :description
    t.float :price
    t.float :sales_price

    t.timestamps
  end
end

class Product < ActiveRecord::Base
  validates :sales_price, numericality: {only_integer: true, less_than_or_equal_to: :price}, allow_blank: true
  validates :price, presence: true, allow_nil: false
end

class BugTest < Minitest::Test
  def test_validates_numericality_of
    product_params = {
      name: "First Product",
      description: "Product Desc; the best of all products",
      price: "",
      sales_price: "23"
    }
    assert Product.create!(product_params)
    # assert_equal 23, Product.first.sales_price
  end
end
