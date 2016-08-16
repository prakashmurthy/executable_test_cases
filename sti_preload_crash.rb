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
  create_table :posts, force: true do |t|
  end

  create_table :comments, force: true do |t|
    t.integer :post_id
    t.integer :user_id
  end

  create_table :users, force: true do |t|
    t.string :type, limit: 255
  end
end

class Post < ActiveRecord::Base
  has_many :comments
  has_many :users, through: :comments
  has_many :one_type_of_users, through: :comments
end

class Comment < ActiveRecord::Base
  belongs_to :post
  belongs_to :user
  belongs_to :one_type_of_users, -> { where type: "OneTypeOfUsers" }, class_name: "User", foreign_key: :user_id
end

class User < ActiveRecord::Base
  has_many :comments
  has_many :users, through: :comments
end

class OneTypeOfUsers < User
end

class AnotherTypeOfUsers < User
end

class BugTest < Minitest::Test
  def test_association_stuff
    post = Post.create!
    user = OneTypeOfUsers.create!
    comment = Comment.create!(post: post, user: user)
    posts_with_preloaded_users = Post.all.includes(:users)
    posts_with_preloaded_one_type_users = Post.all.includes(:one_type_of_users)

    assert_equal comment.user.id, comment.one_type_of_users.id
    assert_equal post.users.first.id, post.one_type_of_users.first.id

    assert_equal posts_with_preloaded_users.first.users.first.id, posts_with_preloaded_one_type_users.first.one_type_of_users.first.id
  end
end
