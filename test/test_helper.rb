require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...

  def login_as(user)
    post "/login", params: { email: users(user).email, password: default_development_password }
    follow_redirect!
  end

  def create_user!
    User.create!(email: "user@example.com", password: default_development_password)
  end

  def default_development_password
    "password"
  end
end
