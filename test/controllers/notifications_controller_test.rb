require 'test_helper'

class NotificationsControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  test "shows the users notifications" do
    users(:john).notifications.create(email: "1111111111@vtext.com")
    users(:john).notifications.create(email: "2222222222@vtext.com")

    login_as(:john)

    get "/notifications"
    assert_response :success

    users(:john).notifications.each do |notification|
      assert_select 'td', { text: /#{notification.token}/, count: 1 }
      assert_select 'td', { text: /#{notification.token}/, count: 1 }
    end
  end

  test "does not show notifications belonging to someone else" do
    users(:john).notifications.create(email: "1111111111@vtext.com")
    users(:john).notifications.create(email: "2222222222@vtext.com")

    login_as(:jacob)

    get "/notifications"
    assert_response :success

    users(:john).notifications.each do |notification|
      assert_select 'td', { text: /#{notification.token}/, count: 0 }
      assert_select 'td', { text: /#{notification.email}/, count: 0 }
    end
  end

  test "viewing new notification page redirects unless authenticated user" do
    get "/notifications/new"
    follow_redirect!
    assert_equal 200, status
    assert_equal "/login", path
  end

  test "new notification 200s with authenticated user" do
    login_as(:john)

    get "/notifications/new"
    assert_response :success
  end

  test "can create an SMS notification" do
    login_as(:john)

    post "/notifications", params: { carrier: "verizon", phone_number: "1111111111" }
    follow_redirect!
    assert_equal 200, status
    assert_equal "/notifications", path

    assert_equal users(:john).notifications.last.email, "1111111111@vtext.com"
  end

  test "can create an SMS notification with default message" do
    login_as(:john)

    post "/notifications", params: { carrier: "verizon", phone_number: "1111111111", default_message: "Hello world!" }
    follow_redirect!
    assert_equal 200, status
    assert_equal "/notifications", path

    assert_equal users(:john).notifications.last.email, "1111111111@vtext.com"
    assert_equal users(:john).notifications.last.default_message, "Hello world!"

  end

  test "can create an email notification" do
    login_as(:john)

    post "/notifications", params: { email: "some-user@example.com" }
    follow_redirect!
    assert_equal 200, status
    assert_equal "/notifications", path

    assert_equal users(:john).notifications.last.email, "some-user@example.com"
  end

  test "can create an email notification with a default message" do
    login_as(:john)

    post "/notifications", params: { email: "some-user@example.com", default_message: "Hello world!" }
    follow_redirect!
    assert_equal 200, status
    assert_equal "/notifications", path

    assert_equal users(:john).notifications.last.email, "some-user@example.com"
    assert_equal users(:john).notifications.last.default_message, "Hello world!"
  end

  test "flashes error without email or SMS params and does not create notification" do
    login_as(:john)

    original_count = Notification.all.count
    post "/notifications", params: { random: "some text" }

    assert_equal "There was an error creating the notification.", flash[:error]
    assert_equal original_count, Notification.all.count
  end

  test "creating notification redirects unless authenticated user" do
    post "/notifications", params: { carrier: "verizon", phone_number: "1111111111" }
    follow_redirect!
    assert_equal 200, status
    assert_equal "/login", path
  end

  test "can destroy notification" do
    users(:john).notifications.create(email: "1111111111@vtext.com")
    notification_to_delete = users(:john).notifications.create(email: "2222222222@vtext.com")
    original_count = users(:john).notifications.count

    login_as(:john)

    delete "/notifications", params: { notification_id: notification_to_delete.id }
    follow_redirect!
    assert_equal 200, status
    assert_equal "/notifications", path

    assert_equal users(:john).notifications.count, original_count - 1
    assert_equal users(:john).notifications.where(email: "2222222222@vtext.com").count, 0
  end

  test "cannot destroy notification belonging to another user" do
    notification_to_delete = users(:john).notifications.create(email: "2222222222@vtext.com")
    original_count = users(:john).notifications.count

    login_as(:jacob)

    delete "/notifications", params: { notification_id: notification_to_delete.id }
    follow_redirect!
    assert_equal 200, status
    assert_equal "/notifications", path

    assert_equal "There was an error deleting the notification.", flash[:error]
    assert_equal users(:john).notifications.count, original_count
  end

  test "can send test notification" do
    notification = users(:john).notifications.create(email: "2222222222@vtext.com")
    original_sent_count = notification.total_sent

    login_as(:john)

    assert_enqueued_with(job: SendEmailNotificationJob) do
      post "/notifications/test", params: { notification_id: notification.id }
      follow_redirect!
      assert_equal 200, status
      assert_equal "/notifications", path
      assert_equal "Message to 2222222222@vtext.com sent.", flash[:success]

      notification.reload
      assert_equal notification.total_sent, original_sent_count + 1
    end
  end

  test "cannot send test notification for another user" do
    notification = users(:john).notifications.create(email: "2222222222@vtext.com")
    original_sent_count = notification.total_sent

    login_as(:jacob)

    post "/notifications/test", params: { notification_id: notification.id }
    follow_redirect!
    assert_equal 200, status
    assert_equal "/notifications", path
    assert_equal "There was an error sending the test message.", flash[:error]

    notification.reload
    assert_equal notification.total_sent, original_sent_count
  end

  test "can send message by POSTing to the token URL" do
    notification = users(:john).notifications.create(email: "2222222222@vtext.com")
    original_sent_count = notification.total_sent

    login_as(:john)

    assert_enqueued_with(job: SendEmailNotificationJob) do
      post "/#{notification.token}", params: { message: "My custom message" }

      assert_response :success
      assert_equal response.body, "\nNotification sent."

      notification.reload
      assert_equal notification.total_sent, original_sent_count + 1
    end
  end

  test "hitting non-existent notification URL 404s" do
    login_as(:john)

    post "/4957ed786c9607823a2c42d993b99de4", params: { message: "My custom message" }

    assert_response :not_found
    assert_equal response.body, "Notification not found."
  end

  test "hitting improperly formated token URL 404s" do
    login_as(:john)

    post "/4957ed786c9607", params: { message: "My custom message" }

    assert_response :not_found
    assert_equal response.body, "404 Not found"
  end


end
