begin
  require 'bundler/inline'
rescue LoadError => e
  $stderr.puts 'Bundler version 1.10 or later is required. Please update your Bundler'
  raise e
end

gemfile(true) do
  source 'https://rubygems.org'
  # Activate the gem you are reporting the issue against.
  gem 'rails', '5.0.0'
end

require 'rack/test'
require 'action_controller/railtie'

class TestApp < Rails::Application
  config.root = File.dirname(__FILE__)
  config.session_store :cookie_store, key: 'cookie_store_key'
  secrets.secret_token    = 'secret_token'
  secrets.secret_key_base = 'secret_key_base'

  config.logger = Logger.new($stdout)
  Rails.logger  = config.logger

  routes.draw do
    get '/' => 'test#index'
    root 'test#index'
    namespace :admin do
      root 'test#index'
    end
  end
end

class TestController < ActionController::Base
  include Rails.application.routes.url_helpers

  def index
    render plain: 'Home'
  end
end

module Admin
  class TestController < ActionController::Base
    include Rails.application.routes.url_helpers

    def index
      render plain: 'Home'
    end
  end
end

require 'minitest/autorun'

# Ensure backward compatibility with Minitest 4
Minitest::Test = MiniTest::Unit::TestCase unless defined?(Minitest::Test)

class BugTest < Minitest::Test
  include Rack::Test::Methods
    include Rails.application.routes.url_helpers

  def test_returns_success
    assert_equal root_path, '/'
  end

  private
  def app
    Rails.application
  end
end
