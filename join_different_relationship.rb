##############################################################################
# For http://stackoverflow.com/questions/39085158/join-on-two-tables-with-different-relationships
##############################################################################
begin
  require "bundler/inline"
rescue LoadError => e
  $stderr.puts "Bundler version 1.10 or later is required. Please update your Bundler"
  raise e
end

gemfile(true) do
  source "https://rubygems.org"
  gem "rails", github: "rails/rails"
  gem "sqlite3"
end

require "active_record"
require "minitest/autorun"
require "logger"

# This connection will do for database-independent bug reports.
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table :offices, force: true do |t|
  end

  create_table :people, force: true do |t|
    t.integer :office_id
  end

  create_table :contact_attempts, force: true do |t|
    t.integer :person_id
    t.integer :office_id
     
    t.timestamps
  end
end

class Office < ActiveRecord::Base
  has_many :people
  has_many :contact_attempts
end

class Person < ActiveRecord::Base
  belongs_to :office
  has_many :contact_attempts
end

class ContactAttempt < ActiveRecord::Base
  belongs_to :office
  belongs_to :person
end

class JoinTest < Minitest::Test
  def test_association_stuff
    # Office1: One unsuccessful contact attempt
    office1 = Office.create!
    office1_person1 = Person.create!(office: office1)
    office1_person2 = Person.create!(office: office1)
    contact_attempt1 = ContactAttempt.create!(office: office1)

    # Office2: Successfully contacted person2
    office2 = Office.create!
    office2_person1 = Person.create!(office: office2)
    office2_person2 = Person.create!(office: office2)
    contact_attempt2 = ContactAttempt.create!(office: office2, person: office2_person2)

    # Office3: Successfully contacted both person1 and person2
    office3 = Office.create!
    office3_person1 = Person.create!(office: office3)
    office3_person2 = Person.create!(office: office3)
    contact_attempt3 = ContactAttempt.create!(office: office3, person: office3_person1)
    contact_attempt4 = ContactAttempt.create!(office: office3, person: office3_person2)

    # Office4: No contact whatsoever
    office4 = Office.create!
    office4_person1 = Person.create!(office: office4)
    office4_person2 = Person.create!(office: office4)

    # List of contacted offices
    assert_equal [office1, office2, office3], Office.joins(:contact_attempts).where(contact_attempts: {created_at: 10.minutes.ago..10.minutes.since}).uniq

    # List of contated people
    assert_equal [office2_person2, office3_person1, office3_person2], Person.joins(:contact_attempts).where(contact_attempts: {created_at: 10.minutes.ago..10.minutes.since}).uniq
  end
end
