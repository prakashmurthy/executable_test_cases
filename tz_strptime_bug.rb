begin
  require 'bundler/inline'
rescue LoadError => e
  $stderr.puts 'Bundler version 1.10 or later is required. Please update your Bundler'
  raise e
end

gemfile(true) do
  source 'https://rubygems.org'
  # Activate the gem you are reporting the issue against.
  gem 'activesupport', '5.0.0'
end

require "active_support/all"
require 'minitest/autorun'
require 'logger'

# Ensure backward compatibility with Minitest 4
Minitest::Test = MiniTest::Unit::TestCase unless defined?(Minitest::Test)

class BugTest < Minitest::Test
  def test_tz_strptime
    tz = ActiveSupport::TimeZone["Eastern Time (US & Canada)"]
    puts %|Good: tz.strptime("2014-04-13", "%Y-%m-%d")|
    p tz.strptime("2014-04-13", "%Y-%m-%d")

    puts %|Good: tz.strptime("2014-04-13 21:20:50", "%Y-%m-%d")|
    p tz.strptime("2014-04-13 21:20:50", "%Y-%m-%d")

    puts %|Bad: tz.strptime("2014-04-13 21:20:50", "%m/%d/%Y")|
    p tz.strptime("2014-04-13 21:20:50", "%m/%d/%Y")
  end
end
