require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "registration page renders for unauthenticated users" do
    get "/register"
    assert_response :success
  end

  test "registration page redirects for authenticated users" do
    login_as(:john)

    get "/register"
    follow_redirect!
    assert_equal 200, status
    assert_equal "/", path
  end

  test "registering redirects for authenticated users" do
    login_as(:john)

    post "/users", params: { email: "newuser@example.com", password: default_development_password }
    follow_redirect!
    assert_equal 200, status
    assert_equal "/", path
  end

  test "registering succeeds for unauthenticated users" do
    assert_nil User.find_by(email: "newuser@example.com")

    post "/users", params: { email: "newuser@example.com", password: default_development_password }
    follow_redirect!
    assert_equal 200, status
    assert_equal "/", path

    assert_equal "Your account has been created.", flash[:success]
    assert_not_nil User.find_by(email: "newuser@example.com")
  end

  test "registering signs you into new account" do
    # Make request to get `session` object loaded in this context
    get "/"
    assert_nil session[:user_id]

    post "/users", params: { email: "newuser@example.com", password: default_development_password }
    assert_equal session[:user_id], User.find_by(email: "newuser@example.com").id
  end

  test "registering fails without email" do
    assert_nil User.find_by(email: "newuser@example.com")

    post "/users", params: { password: default_development_password }
    assert_response :success

    assert_equal "Email can't be blank", flash[:error]
  end

  test "registering fails without password" do
    assert_nil User.find_by(email: "newuser@example.com")

    post "/users", params: { email: "newuser@example.com" }
    assert_response :success

    assert_equal "Password can't be blank and Password is too short (minimum is 8 characters)", flash[:error]
  end

end
