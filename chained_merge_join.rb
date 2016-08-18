##############################################################################
# Script for https://github.com/rails/rails/issues/26198
##############################################################################
begin
  require "bundler/inline"
rescue LoadError => e
  $stderr.puts "Bundler version 1.10 or later is required. Please update your Bundler"
  raise e
end

gemfile(true) do
  source "https://rubygems.org"
  # gem "rails", '5.0.0' # works
  # gem "rails", '4.2.5.2' # works
  gem "rails", github: 'rails/rails' # works
  gem "sqlite3"
end

require "active_record"
require "minitest/autorun"
require "logger"

# This connection will do for database-independent bug reports.
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table :sites, force: true do |t|
  end

  create_table :blogs, force: true do |t|
    t.integer :site_id
  end

  create_table :comments, force: true do |t|
    t.integer :blog_id
  end

  create_table :words, force: true do |t|
    t.integer :comment_id
  end
end

class Site < ActiveRecord::Base
  has_many :blogs
end

class Blog < ActiveRecord::Base
  belongs_to :site
  has_many :comments
end

class Comment < ActiveRecord::Base
  belongs_to :blog
  has_many :words
end

class Word < ActiveRecord::Base
  belongs_to :comment
end

class BugTest < Minitest::Test
  def test_chained_merge_with_joins
    site = Site.create!

    blog1 = Blog.create!(site: site)
    blog2 = Blog.create!(site: site)

    comment1 = Comment.create!(blog: blog1)
    comment2 = Comment.create!(blog: blog1)
    comment3 = Comment.create!(blog: blog1)
    comment4 = Comment.create!(blog: blog2)

    word1 = Word.create!(comment: comment1)
    word2 = Word.create!(comment: comment2)
    word3 = Word.create!(comment: comment3)
    word4 = Word.create!(comment: comment3)
    word5 = Word.create!(comment: comment4)

    sql_query_1 = 'SELECT "words".* FROM "words" INNER JOIN "comments" ON "comments"."id" = "words"."comment_id" LEFT OUTER JOIN "blogs" ON "blogs"."id" = "comments"."blog_id" LEFT OUTER JOIN "sites" ON "sites"."id" = "blogs"."site_id"'
    sql_query_2 = 'SELECT "words".* FROM "words" INNER JOIN "comments" ON "comments"."id" = "words"."comment_id" LEFT OUTER JOIN "sites" ON "sites"."id" = "blogs"."site_id" LEFT OUTER JOIN "blogs" ON "blogs"."id" = "comments"."blog_id"'

    # assert_equal sql_query_1, Word.joins(:comment).merge(Comment.joins(:blog).merge(Blog.joins(:site))).to_sql
    assert_equal sql_query_2, Word.joins(:comment).merge(Comment.joins(:blog).merge(Blog.joins(:site))).to_sql
    assert_equal [word1, word2, word3, word4, word5], Word.joins(:comment).merge(Comment.joins(:blog).merge(Blog.joins(:site)))
  end
end
