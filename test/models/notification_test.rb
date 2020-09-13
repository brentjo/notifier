require 'test_helper'

class NotificationTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "token and total sent are set" do
    user = create_user!
    notification = user.notifications.create!(email: "1111111111@vtext.com")

    assert_match /\h{32}/, notification.token
    assert_equal 0, notification.total_sent
  end

  test "owner must be under notification limit" do
    user = create_user!
    (0...Notification::MAX_NOTIFICATIONS).each do |num|
      user.notifications.create!(email: "1111111111@vtext.com")
    end

    notification = user.notifications.new(email: "1111111111@vtext.com")
    refute notification.valid?
    assert_equal ["can't have more than 10 notifications"], notification.errors.messages[:users]
  end

  test "sending notification queues job and sets metadata" do
    user = create_user!
    notification = user.notifications.create!(email: "1111111111@vtext.com")

    assert_equal notification.total_sent, 0
    assert_nil notification.last_sent

    job = assert_enqueued_with(job: SendEmailNotificationJob) do
      notification.send_notification("Hello world!")
    end

    assert_equal job.arguments.first, "1111111111@vtext.com"
    assert_equal job.arguments.second, "Hello world!"

    assert_equal notification.total_sent, 1
    assert_not_nil notification.last_sent
  end

  test "send_notification will first parameter as message" do
    user = create_user!
    notification = user.notifications.create!(email: "1111111111@vtext.com")

    job = assert_enqueued_with(job: SendEmailNotificationJob) do
      notification.send_notification("Hello world!")
    end

    assert_equal job.arguments.first, "1111111111@vtext.com"
    assert_equal job.arguments.second, "Hello world!"
  end

  test "send_notification prioritizes messages param to default_message set" do
    user = create_user!
    notification = user.notifications.create!(email: "1111111111@vtext.com", default_message: "Default message")

    job = assert_enqueued_with(job: SendEmailNotificationJob) do
      notification.send_notification("Hello world!")
    end

    assert_equal job.arguments.second, "Hello world!"
  end

  test "send_notification falls back to default_message set" do
    user = create_user!
    notification = user.notifications.create!(email: "1111111111@vtext.com", default_message: "Default message")

    job = assert_enqueued_with(job: SendEmailNotificationJob) do
      notification.send_notification
    end

    assert_equal job.arguments.second, "Default message"
  end

  test "send_notification falls back to generic message if no parameter or default set" do
    user = create_user!
    notification = user.notifications.create!(email: "1111111111@vtext.com")

    job = assert_enqueued_with(job: SendEmailNotificationJob) do
      notification.send_notification
    end

    assert_equal job.arguments.second, "Alert from NotifierAPI. No custom message was specified."
  end
end
