require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest

  test "login" do
    get "/login"

    assert_equal 200, status
    assert_nil session[:user_id]

    original_session_count = ActiveRecord::SessionStore::Session.all.count

    post "/login", params: { email: users(:john).email, password: default_development_password }
    follow_redirect!
    assert_equal 200, status
    assert_equal "/notifications", path

    assert_equal session[:user_id], users(:john).id
    assert_equal ActiveRecord::SessionStore::Session.all.count, original_session_count + 1
  end

  test "logout" do
    post "/login", params: { email: users(:john).email, password: default_development_password }
    follow_redirect!
    assert_equal 200, status
    assert_equal "/notifications", path

    session_id = session.id
    assert_not_nil ActiveRecord::SessionStore::Session.find_by_session_id(session_id)

    post "/logout"
    follow_redirect!
    assert_equal 200, status
    assert_equal "/", path

    assert_nil ActiveRecord::SessionStore::Session.find_by_session_id(session_id)
  end
end
