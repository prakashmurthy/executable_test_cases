require 'bundler/inline'

gemfile(true) do
  source 'https://rubygems.org'
  # gem 'activerecord', git: 'https://github.com/rails/rails.git', ref: 'e16afe61abd78'
  gem 'activerecord', path: '~/Projects/rails' #, ref: '173bf3506d99c0'
  gem 'arel', github: "rails/arel", ref: '3c429c5d86e9'
  gem 'pg'
end

require 'active_record'
require 'minitest/autorun'
require 'logger'

ActiveRecord::Base.establish_connection(adapter: 'postgresql', port: 5432)
#ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Schema.define do
  create_table :users, temporary: true do |t|
    t.string :name
    t.boolean :deleted, null: false, default: false
    t.timestamps null: false
  end

  create_table :emails, temporary: true do |t|
    t.belongs_to :user
    t.string :addr
    t.boolean :deleted, null: false, default: false
  end
end

if defined? ActiveSupport.halt_callback_chains_on_return_false=
  ActiveSupport.halt_callback_chains_on_return_false = false
end

class User < ActiveRecord::Base
  has_many :emails

  after_save do
    # synchronize associated emails' deleted flag - FAIL HERE
    emails.update_all(deleted: deleted?)
    true
  end
end
class Email < ActiveRecord::Base
  belongs_to :User
end

class BugTest < Minitest::Test
  # PASS - assign primary key BEFORE association
  # def test_pass1
  #   # person = Person.new
  #   # person.id = 10
  #   # person.name = 'FooBar'
  #   # person.emails = [Email.new(addr: 'test1@example.com')]
  #   # person.emails
  #   # person.save!
  #   # assert Person.find(10)
  # end

  # # PASS - don't access association
  # def test_pass2
  #   # person = Person.new
  #   # person.name = 'FooBar'
  #   # person.emails = [Email.new(addr: 'test2@example.com')]
  #   # person.id = 11
  #   # person.save!
  #   # assert Person.find(11)
  # end

  # FAIL - assign primary key AFTER association, and then access association
  def test_fail
    person = User.new
    person.name = 'FooBar'
    person.emails = [Email.new(addr: 'test3@example.com')]
    person.id = 12
    person.emails
    person.save!
    assert User.find(12)
  end
end
