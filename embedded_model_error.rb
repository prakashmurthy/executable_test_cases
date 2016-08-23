##############################################################################
# Script for https://github.com/rails/rails/issues/25806
##############################################################################
begin
  require "bundler/inline"
rescue LoadError => e
  $stderr.puts "Bundler version 1.10 or later is required. Please update your Bundler"
  raise e
end

gemfile(true) do
  source "https://rubygems.org"
  gem "rails", github: 'rails/rails'
  gem "pg", "~> 0.18.4"
end

require "active_record"
require "minitest/autorun"
require "logger"

# This connection will do for database-independent bug reports.
ActiveRecord::Base.establish_connection(adapter: "postgresql", database: "rails_app_care_test")
ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table :organizations, force: true do |t|
  end

  create_table :lots, force: true do |t|
    t.integer :customer_id
  end

  create_table :lot_items, force: true do |t|
    t.integer :lot_id
    t.integer :okpd_id
  end

  create_table :tree_classifiers, force: true do |t|
    t.integer :type
    t.string :code
  end
end

class Organization < ActiveRecord::Base
  has_many :lots, inverse_of: :customer, foreign_key: :customer_id
  scope :by_okpd_code, ->(okpd_code) { joins(:lots).merge(Lot.by_okpd_code(okpd_code)) }
end

class Lot < ActiveRecord::Base
  belongs_to :customer, class_name: :Organization, inverse_of: :lots
  has_many :lot_items
  scope :by_okpd_code, ->(okpd_code) { joins(:lot_items).merge(LotItem.by_okpd_code(okpd_code)) }
end

class LotItem < ActiveRecord::Base
  belongs_to :lot
  belongs_to :okpd
  scope :by_okpd_code, ->(okpd_code) { joins(:okpd).where(tree_classifiers: { code: okpd_code } ) }
end

class TreeClassifier < ActiveRecord::Base
end

class Okpd < TreeClassifier
end

class BugTest < Minitest::Test
  def test_chained_merge_with_joins
    organization = Organization.create!

    lot1 = Lot.create!(customer: organization)
    lot2 = Lot.create!(customer: organization)

    okpd1 = Okpd.create!(code: '60.77.43')
    okpd2 = Okpd.create!(code: '60.77.44')

    lot1_item1 = LotItem.create!(lot: lot1, okpd: okpd1)
    lot1_item2 = LotItem.create!(lot: lot1, okpd: okpd2)

    lot2_item1 = LotItem.create!(lot: lot2, okpd: okpd1)
    lot2_item2 = LotItem.create!(lot: lot2, okpd: okpd2)


    expected_sql_query_as_per_op = 'SELECT "organizations".* FROM "organizations" INNER JOIN "lots" ON "lots"."customer_id" = "organizations"."id" LEFT OUTER JOIN "lot_items" ON "lot_items"."lot_id" = "lots"."id" LEFT OUTER JOIN "tree_classifiers" ON "tree_classifiers"."id" = "lot_items"."okpd_id" AND "tree_classifiers"."type" IN ("Okpd") WHERE "organizations"."id" IN (SELECT DISTINCT "lots"."customer_id" FROM "lots") AND "tree_classifiers"."code" = "60.77.43"'
    actual_sql_query_as_per_op = 'SELECT "organizations".* FROM "organizations" INNER JOIN "lots" ON "lots"."customer_id" = "organizations"."id" LEFT OUTER JOIN "tree_classifiers" ON "tree_classifiers"."id" = "lot_items"."okpd_id" AND "tree_classifiers"."type" IN ("Okpd") LEFT OUTER JOIN "lot_items" ON "lot_items"."lot_id" = "lots"."id" WHERE "organizations"."id" IN (SELECT DISTINCT "lots"."customer_id" FROM "lots") AND "tree_classifiers"."code" = "60.77.43"'

    actual_sql_query = 'SELECT "organizations".* FROM "organizations" INNER JOIN "lots" ON "lots"."customer_id" = "organizations"."id" LEFT OUTER JOIN "tree_classifiers" ON "tree_classifiers"."id" = "lot_items"."okpd_id" AND "tree_classifiers"."type" IN (\'Okpd\') LEFT OUTER JOIN "lot_items" ON "lot_items"."lot_id" = "lots"."id" WHERE "tree_classifiers"."code" = \'60.77.43\''

    assert_equal actual_sql_query, Organization.by_okpd_code("60.77.43").to_sql
    assert_equal [], Organization.by_okpd_code("60.77.43")
  end
end

