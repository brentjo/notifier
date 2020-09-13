require 'test_helper'

class NotificationMailerTest < ActionMailer::TestCase
  test "sends an email" do
    email = NotificationMailer.bare_email("user@example.com", "Hello world!").deliver_now

    refute ActionMailer::Base.deliveries.empty?
    assert_equal ["no-reply@notifierapi.herokuapp.com"], email.from
    assert_equal ["user@example.com"], email.to
    assert_equal "NotifierAPI", email.subject
    assert_equal "Hello world!\n\n", email.body.to_s
  end
end
